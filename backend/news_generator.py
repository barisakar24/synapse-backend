import feedparser
import json
import os
import requests
import random
from datetime import datetime
from openai import OpenAI

# --- AYARLAR ---
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
GITHUB_REPO_URL = "https://raw.githubusercontent.com/barisakar24/synapse-backend/master/backend/images/"
JSON_FILE = 'news_data.json'
IMAGE_FOLDER = 'images'

RSS_URLS = [
    "https://neurosciencenews.com/feed/",
    "https://www.sciencedaily.com/rss/mind_brain.xml",
    "https://www.medicalnewstoday.com/rss/psychology-psychiatry",
    "https://www.technologyreview.com/feed/",
    "https://www.genengnews.com/feed/"
]

CATEGORIES = {
    "Nöroloji": ["brain", "neuron", "synapse", "alzheimer", "parkinson", "stroke", "neuro"],
    "Psikoloji": ["psychology", "behavior", "mental", "depression", "anxiety", "cognitive"],
    "Yapay Zeka": ["artificial intelligence", "ai", "machine learning", "robot", "algorithm"],
    "Genetik": ["gene", "dna", "rna", "mutation", "genome", "crispr"]
}

def ensure_directories():
    if not os.path.exists(IMAGE_FOLDER):
        os.makedirs(IMAGE_FOLDER)

def load_existing_news():
    if os.path.exists(JSON_FILE):
        with open(JSON_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data.get('news_list', [])
    return []

def assign_category(text):
    text = text.lower()
    for cat, keywords in CATEGORIES.items():
        for word in keywords:
            if word in text:
                return cat
    return "Bilim & Teknoloji"

def generate_content_and_image(title, summary, link, source_name):
    """GPT-4o ile Başlık/Makale ve DALL-E 3 ile Görsel Üretir"""
    try:
        # 1. METİN VE BAŞLIK ÜRETİMİ
        print(f"🧠 GPT Analiz Ediyor: {title[:30]}...")
        prompt = (
            f"Haber: {title}\nÖzet: {summary}\nKaynak: {source_name}\n\n"
            f"GÖREVLER:\n"
            f"1. Bu haber için çok çarpıcı, 'clickbait' olmayan ama ilgi çekici TÜRKÇE bir başlık yaz.\n"
            f"2. Haberi Türkçe'ye çevirip 4-5 paragraflık zengin bir makale haline getir.\n"
            f"3. En alta APA formatında kaynak ekle.\n"
            f"4. Yanıtı tam olarak şu JSON formatında ver (başka hiçbir şey yazma):\n"
            f'{{"title": "Türkçe Başlık", "content": "Makale içeriği...", "image_prompt": "DALL-E için İngilizce görsel tarifi"}}'
        )

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.7
        )
        
        gpt_data = json.loads(response.choices[0].message.content)
        
        # 2. GÖRSEL ÜRETİMİ (DALL-E 3)
        print(f"🎨 Görsel Çiziliyor...")
        image_response = client.images.generate(
            model="dall-e-3",
            prompt=f"Cinematic, elegant, high-tech, abstract neuroscience or technology style, dark mode aesthetic, 8k resolution. Context: {gpt_data['image_prompt']}",
            size="1024x1024",
            quality="standard",
            n=1,
        )
        image_url = image_response.data[0].url
        
        # 3. GÖRSELİ İNDİR VE KAYDET
        img_filename = f"img_{int(datetime.now().timestamp())}_{random.randint(100,999)}.png"
        img_path = os.path.join(IMAGE_FOLDER, img_filename)
        
        img_data = requests.get(image_url).content
        with open(img_path, 'wb') as handler:
            handler.write(img_data)
            
        final_image_url = GITHUB_REPO_URL + img_filename
        
        return gpt_data['title'], gpt_data['content'], final_image_url

    except Exception as e:
        print(f"Hata oluştu: {e}")
        return None, None, None

def main():
    ensure_directories()
    existing_news = load_existing_news()
    existing_links = [n['link'] for n in existing_news]
    
    new_articles = []
    print("🌍 RSS Taraması Başlıyor...")

    for url in RSS_URLS:
        try:
            feed = feedparser.parse(url)
            source_name = feed.feed.get('title', 'Science Source')
            
            # Her kaynaktan en yeni 1 haberi kontrol et (API tasarrufu için az tutuyoruz)
            for entry in feed.entries[:1]:
                link = entry.link
                
                # --- DEDUPLICATION (AYNI HABER VARSA GEÇ) ---
                if link in existing_links:
                    print(f"♻️ Zaten var: {entry.title[:30]}")
                    continue

                title = entry.title
                summary = getattr(entry, 'summary', '')
                
                # GPT ve DALL-E İşlemi
                tr_title, content, image_url = generate_content_and_image(title, summary, link, source_name)
                
                if tr_title and content and image_url:
                    news_item = {
                        "title": tr_title, # Artık Türkçe!
                        "original_title": title,
                        "content": content,
                        "category": assign_category(title + " " + summary),
                        "image": image_url, # GitHub'daki kalıcı link
                        "link": link,
                        "date": datetime.now().isoformat(),
                        "timestamp": datetime.now().timestamp()
                    }
                    new_articles.append(news_item)
                    print(f"✅ Yeni Makale Eklendi: {tr_title}")
                
        except Exception as e:
            print(f"RSS Hatası: {e}")

    # Yeni haberleri eskilere ekle (En yeniler en başa)
    updated_news_list = new_articles + existing_news
    
    # Listeyi 50 haberle sınırla ki dosya şişmesin
    updated_news_list = updated_news_list[:50]

    # Günün haberi: Son 24 saatte eklenenlerden rastgele biri, yoksa en yenisi
    now_ts = datetime.now().timestamp()
    recent_ones = [n for n in updated_news_list if (now_ts - n['timestamp']) < 86400]
    daily_news = random.choice(recent_ones) if recent_ones else updated_news_list[0]

    final_data = {
        "last_updated": datetime.now().isoformat(),
        "daily_news": daily_news,
        "news_list": updated_news_list
    }

    with open(JSON_FILE, 'w', encoding='utf-8') as f:
        json.dump(final_data, f, ensure_ascii=False, indent=4)

    print(f"🏁 İşlem Tamam. {len(new_articles)} yeni haber eklendi.")

if __name__ == "__main__":
    main()