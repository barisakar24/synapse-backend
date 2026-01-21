import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsData;

  const NewsDetailScreen({super.key, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: CustomScrollView(
        slivers: [
          // 1. Resimli Başlık (SliverAppBar)
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F1115),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                newsData['image'] ?? "https://picsum.photos/800",
                fit: BoxFit.cover,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 2. İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Etiketi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2962FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      newsData['category'] ?? "Genel",
                      style: const TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Başlık
                  Text(
                    newsData['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tarih
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        "AI tarafından oluşturuldu • Synapse",
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 40),

                  // GPT-4o Makale Metni
                  Text(
                    newsData['content'] ?? newsData['original_summary'] ?? "İçerik yüklenemedi.",
                    style: GoogleFonts.merriweather( // Okuma için serif font daha iyidir
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.8,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Orijinal Kaynak Linki Butonu
                  if (newsData['link'] != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // url_launcher ile açılabilir
                        },
                        icon: const Icon(Icons.link, color: Colors.white),
                        label: const Text("Orijinal Kaynağa Git", style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}