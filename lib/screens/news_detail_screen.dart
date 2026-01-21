import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  // Tema Renkleri
  final Color _accentColor = const Color(0xFFFFD233); // Neon Sarı
  final Color _backgroundColor = const Color(0xFF0F1115);
  final Color _surfaceColor = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. Üst Kısım: Hareketli (Paralaks) Görsel
          SliverAppBar(
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            backgroundColor: _backgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGlassButton(
                context, 
                icon: CupertinoIcons.back, 
                onTap: () => Navigator.pop(context)
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGlassButton(context, icon: CupertinoIcons.bookmark, onTap: () {}),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                child: _buildGlassButton(context, icon: CupertinoIcons.share, onTap: () {}),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    "https://picsum.photos/800/800?random=1",
                    fit: BoxFit.cover,
                  ),
                  // Görselin altına siyah gölge atıyoruz ki yazı ile birleştiği yer yumuşak olsun
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          _backgroundColor.withOpacity(0.8),
                          _backgroundColor,
                        ],
                        stops: const [0.0, 0.6, 0.9, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. İçerik Kısmı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Etiketi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "NEUROSCIENCE",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık
                  Text(
                    "Beyin Haritalamada Yeni Dönem: Yapay Zeka Destekli MR Görüntüleme",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Yazar ve Tarih Bilgisi
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://randomuser.me/api/portraits/women/44.jpg"),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doç. Dr. Elif Yılmaz",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "21 Ocak 2026 • 5 dk okuma",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 30),

                  // Haber Metni
                  Text(
                    "Sinirbilim araştırmaları, son yıllarda yapay zeka teknolojilerinin entegrasyonu ile büyük bir ivme kazandı. Özellikle fMRI ve DTI gibi görüntüleme tekniklerinde elde edilen verilerin işlenmesi, klasik yöntemlerle aylar sürerken, yeni geliştirilen algoritmalar sayesinde saniyeler içinde analiz edilebiliyor.\n\n"
                    "Bu yeni yöntem, 'Synapse' adı verilen bir proje kapsamında geliştirildi. Araştırmacılar, beynin daha önce haritalanamayan bölgelerindeki mikro bağlantıları görünür kılmayı başardı.\n\n"
                    "Uzmanlar, bu gelişmenin Alzheimer ve Parkinson gibi nörodejeneratif hastalıkların erken teşhisinde devrim yaratabileceğini belirtiyor. Geleneksel yöntemlerin aksine, bu yeni AI modeli, yapısal bozukluklar oluşmadan önce, sinirsel aktivitedeki mikroskobik değişimleri tespit edebiliyor.",
                    style: GoogleFonts.lora( // Okuma için serif font daha rahattır veya Poppins light kullanılabilir.
                      color: Colors.grey[300],
                      fontSize: 18,
                      height: 1.8, // Satır arası boşluk okumayı kolaylaştırır
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Alıntı Kutusu (Quote)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      border: Border(left: BorderSide(color: _accentColor, width: 4)),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      "“Bu sadece bir başlangıç. Gelecekte beynin dijital bir kopyasını oluşturup, hastalıkları simülasyon ortamında tedavi etmeyi hedefliyoruz.”",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Alt Buton (Call to Action)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Tarayıcı açma kodu buraya gelecek
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Makalenin Tamamını Oku",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  // Özel Glassmorphism Buton Widget'ı
  Widget _buildGlassButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3), // Yarı saydam siyah
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}