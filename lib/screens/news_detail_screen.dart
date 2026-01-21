import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsData;

  const NewsDetailScreen({super.key, required this.newsData});

  // Okuma süresi hesaplama
  String _calculateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final readTime = (wordCount / 200).ceil();
    return "$readTime dk okuma";
  }

  // Tarih formatlama (Türkçe Ay İsimleri ile)
  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      // ISO format veya RSS formatı gelebilir, parse etmeye çalışalım
      final date = DateTime.parse(dateStr); 
      final months = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = newsData['content'] ?? newsData['original_summary'] ?? "İçerik yüklenemedi.";
    final readingTime = _calculateReadingTime(content);
    final dateStr = _formatDate(newsData['date']);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: CustomScrollView(
        slivers: [
          // 1. Resimli Başlık (SliverAppBar)
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F1115),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Image.network(
                newsData['image'] ?? "https://picsum.photos/800",
                fit: BoxFit.cover,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.share, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // 2. İçerik
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F1115),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -10))
                ],
              ),
              transform: Matrix4.translationValues(0, -30, 0), // Hafif yukarı kaydırarak resmi ört
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Çizgi (Handle)
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kategori ve Tarih
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2962FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2962FF).withOpacity(0.3)),
                          ),
                          child: Text(
                            newsData['category'] ?? "Genel",
                            style: GoogleFonts.poppins(color: const Color(0xFF2962FF), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Başlık
                    Text(
                      newsData['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Yazar ve Okuma Süresi
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.smart_toy, color: Color(0xFFFFD700), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Synapse AI", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Editör", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(CupertinoIcons.time, color: Colors.grey, size: 14),
                        const SizedBox(width: 5),
                        Text(readingTime, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Aksiyon Butonları (Dinle, Boyut, Kaydet)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(Icons.play_circle_outline, "Dinle"),
                          _buildVerticalDivider(),
                          _buildActionButton(Icons.text_fields, "Boyut"),
                          _buildVerticalDivider(),
                          _buildActionButton(CupertinoIcons.bookmark, "Kaydet"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Makale İçeriği
                    Text(
                      content,
                      style: GoogleFonts.merriweather(
                        fontSize: 17,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.8,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Orijinal Kaynak Linki Butonu
                    if (newsData['link'] != null)
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [const Color(0xFF2962FF).withOpacity(0.8), const Color(0xFF2962FF).withOpacity(0.4)],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // url_launcher entegrasyonu buraya
                          },
                          icon: const Icon(Icons.open_in_new, color: Colors.white),
                          label: Text("Orijinal Kaynağa Git", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white10,
    );
  }
}