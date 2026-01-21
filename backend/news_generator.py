import feedparser
import json
import random
import os
import time
from datetime import datetime
import dateutil.parser
from openai import OpenAI

# --- AYARLAR ---
# GitHub Actions Secrets'tan API Key'i alacağız
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

RSS_URLS = [
    "https://neurosciencenews.com/feed/",          # Genel Sinirbilim & Nöroloji
    "https://www.sciencedaily.com/rss/mind_brain.xml", # Beyin & Zihin
    "https://www.medicalnewstoday.com/rss/psychology-psychiatry", # Psikoloji
    "https://www.technologyreview.com/feed/",      # Yapay Zeka
    "https://www.genengnews.com/feed/"             # Genetik
]

CATEGORIES = {
    "Nöroloji": ["brain", "neuron", "synapse", "alzheimer", "parkinson", "stroke", "neuro", "cortex"],
    "Psikoloji": ["psychology", "behavior", "mental", "depression", "anxiety", "cognitive", "therapy", "emotion"],
    "Yapay Zeka": ["artificial intelligence", "ai", "machine learning", "robot", "algorithm", "neural network", "chatgpt"],
    "Genetik": ["gene", "dna", "rna", "mutation", "genome", "crispr", "hereditary", "biology"]
}

DEFAULT_IMAGES = {
    "Nöroloji": "https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=800&q=80",
    "Psikoloji": "https://images.unsplash.com/photo-1493836512294-502baa1986e2?auto=format&fit=crop&w=800&q=80",
    "Yapay Zeka": "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=800&q=80",
    "Genetik": "https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=800&q=80",
    "Genel": "https://images.unsplash.com/photo-1507413245164-6160d8298b31?auto=format&fit=crop&w=800&q=80"
}

def get_image(entry):
    """RSS'den resim bulmaya çalışır"""
    if 'media_content' in entry:
        return entry.media_content[0]['url']
    if 'links' in entry:
        for link in entry.links:
            if 'image' in link.type:
                return link.href
    return None

def assign_category(text):
    text = text.lower()
    for cat, keywords in CATEGORIES.items():
        for word in keywords:
            if word in text:
                return cat
    return "Tüm Haberler"

def generate_article_with_gpt4o(title, summary, link, source_name):
    """GPT-4o kullanarak makale ve APA kaynakça oluşturur"""
    try:
        print(f"🤖 GPT-4o Analiz Ediyor: {title[:30]}...")
        
        prompt = (
            f"Aşağıdaki haber başlığı ve özetini kullanarak, uzman bir sinirbilim yazarı gibi davran.\n"
            f"Konu: {title}\nÖzet: {summary}\nKaynak: {source_name}\nLink: {link}\n\n"
            f"İstekler:\n"
            f"1. Bu haberi Türkçe'ye çevir ve detaylandır.\n"
            f"2. En az 5-6 paragraf uzunluğunda, akademik ama anlaşılır bir makale yaz.\n"
            f"3. Makalenin en sonuna 'KAYNAKÇA' başlığı altında, bu haberi APA formatında kaynak göster (Erişim tarihi bugünün tarihi olsun).\n"
            f"4. Sadece makale metnini ve kaynakçayı ver, başka bir şey yazma."
        )

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "Sen Synapse uygulaması için içerik üreten uzman bir bilim editörüsün."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"GPT Hatası: {e}")
        return f"{summary}\n\n(Yapay zeka özeti oluşturulamadı. Orijinal kaynak: {link})"

def main():
    all_news = []
    print("🌍 Haberler taranıyor...")

    for url in RSS_URLS:
        try:
            feed = feedparser.parse(url)
            source_name = feed.feed.get('title', 'Science Source')
            
            # Her kaynaktan sadece en yeni 2 haberi alalım (API kotası şişmesin)
            for entry in feed.entries[:2]:
                title = entry.title
                link = entry.link
                summary = getattr(entry, 'summary', '')
                pub_date = getattr(entry, 'published', str(datetime.now()))
                
                # Kategori ve Resim
                cat = assign_category(title + " " + summary)
                img = get_image(entry) or DEFAULT_IMAGES.get(cat, DEFAULT_IMAGES["Genel"])

                # GPT-4o ile İçerik Üretimi
                full_content = generate_article_with_gpt4o(title, summary, link, source_name)

                news_item = {
                    "title": title, # Orijinal başlık (veya istersen GPT'ye başlık da attırabilirsin)
                    "original_summary": summary,
                    "content": full_content, # GPT'nin yazdığı uzun makale
                    "category": cat,
                    "image": img,
                    "link": link,
                    "date": pub_date,
                    "timestamp": datetime.now().timestamp()
                }
                all_news.append(news_item)
                
        except Exception as e:
            print(f"Hata ({url}): {e}")

    # En yeni haber en üstte
    all_news.sort(key=lambda x: x['timestamp'], reverse=True)

    # Günün Haberi (Rastgele bir tanesi)
    daily_news = random.choice(all_news) if all_news else None

    # JSON Kaydı
    final_data = {
        "last_updated": datetime.now().isoformat(),
        "daily_news": daily_news,
        "news_list": all_news
    }

    with open('news_data.json', 'w', encoding='utf-8') as f:
        json.dump(final_data, f, ensure_ascii=False, indent=4)

    print(f"✅ İşlem Tamam! {len(all_news)} makale oluşturuldu.")

if __name__ == "__main__":
    main()