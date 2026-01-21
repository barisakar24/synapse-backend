import feedparser
import json
import os
import random
from datetime import datetime
from openai import OpenAI

# --- AYARLAR ---
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
JSON_FILE = 'news_data.json'

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

# Eğer haberde resim yoksa kullanılacak yedekler
DEFAULT_IMAGES = {
    "Nöroloji": "https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=800&q=80",
    "Psikoloji": "https://images.unsplash.com/photo-1493836512294-502baa1986e2?auto=format&fit=crop&w=800&q=80",
    "Yapay Zeka": "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=800&q=80",
    "Genetik": "https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=800&q=80",
    "Genel": "https://images.unsplash.com/photo-1507413245164-6160d8298b31?auto=format&fit=crop&w=800&q=80"
}

def load_existing_news():
    if os.path.exists(JSON_FILE):
        with open(JSON_FILE, 'r', encoding='utf-8') as f:
            return json.load(f).get('news_list', [])
    return []

def get_image_from_rss(entry, category):
    """RSS'den resim bulur, yoksa kategoriye göre varsayılanı verir"""
    if 'media_content' in entry:
        return entry.media_content[0]['url']
    if 'links' in entry:
        for link in entry.links:
            if 'image' in link.type:
                return link.href
    return DEFAULT_IMAGES.get(category, DEFAULT_IMAGES["Genel"])

def assign_category(text):
    text = text.lower()
    for cat, keywords in CATEGORIES.items():
        for word in keywords:
            if word in text:
                return cat
    return "Bilim & Teknoloji"

def generate_turkish_content(title, summary, source_name):
    """Sadece Metin ve Başlık Üretir (DALL-E Yok)"""
    try:
        print(f"🧠 GPT Analiz Ediyor: {title[:30]}...")
        prompt = (
            f"Haber: {title}\nÖzet: {summary}\nKaynak: {source_name}\n\n"
            f"GÖREVLER:\n"
            f"1. Bu haber için ilgi çekici TÜRKÇE bir başlık yaz.\n"
            f"2. Haberi Türkçe'ye çevirip detaylı bir makale haline getir.\n"
            f"3. En alta APA formatında kaynak ekle.\n"
            f"4. Yanıtı SADECE şu JSON formatında ver:\n"
            f'{{"title": "Türkçe Başlık", "content": "Makale içeriği..."}}'
        )

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.7
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        print(f"GPT Hatası: {e}")
        return None

def main():
    existing_news = load_existing_news()
    existing_links = [n['link'] for n in existing_news]
    
    new_articles = []
    print("🌍 RSS Taraması Başlıyor...")

    for url in RSS_URLS:
        try:
            feed = feedparser.parse(url)
            source_name = feed.feed.get('title', 'Science Source')
            
            for entry in feed.entries[:2]: # Her siteden en yeni 2 haberi kontrol et
                link = entry.link
                
                if link in existing_links:
                    continue # Zaten varsa geç

                title = entry.title
                summary = getattr(entry, 'summary', '')
                
                # GPT ile Türkçe içerik üret
                gpt_result = generate_turkish_content(title, summary, source_name)
                
                if gpt_result:
                    category = assign_category(title + " " + summary)
                    # Resmi RSS'den al, yoksa stok foto kullan
                    image_url = get_image_from_rss(entry, category)

                    news_item = {
                        "title": gpt_result['title'],
                        "original_title": title,
                        "content": gpt_result['content'],
                        "category": category,
                        "image": image_url, 
                        "link": link,
                        "date": datetime.now().isoformat(),
                        "timestamp": datetime.now().timestamp()
                    }
                    new_articles.append(news_item)
                    print(f"✅ Eklendi: {gpt_result['title']}")
                
        except Exception as e:
            print(f"RSS Hatası: {e}")

    updated_news_list = new_articles + existing_news
    updated_news_list = updated_news_list[:50] # Liste çok şişmesin

    # Günün haberi seçimi
    if new_articles:
        daily_news = random.choice(new_articles)
    elif updated_news_list:
        daily_news = updated_news_list[0]
    else:
        daily_news = None

    final_data = {
        "last_updated": datetime.now().isoformat(),
        "daily_news": daily_news,
        "news_list": updated_news_list
    }

    with open(JSON_FILE, 'w', encoding='utf-8') as f:
        json.dump(final_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()