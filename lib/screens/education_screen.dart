import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_player_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  // Referanstaki Gold/Sarı tonu
  final Color _accentColor = const Color(0xFFFFD700); 
  final Color _backgroundColor = const Color(0xFF000000); // Tam siyah Netflix tarzı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true, // İçeriğin status bar arkasına geçmesini sağlar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VİTRİN BÖLÜMÜ (HERO SECTION)
            _buildFeaturedSection(context),

            const SizedBox(height: 20),

            // 2. YATAY LİSTELER
            _buildSectionTitle("Sizin İçin Önerilenler"),
            _buildHorizontalList(height: 220, width: 150, showTag: true),

            _buildSectionTitle("Popüler Nöroanatomi Serileri"),
            _buildHorizontalList(height: 180, width: 280, isWide: true), // Geniş kartlar

            _buildSectionTitle("Klinik Sinirbilim & Vaka Analizleri"),
            _buildHorizontalList(height: 220, width: 150),
            
            const SizedBox(height: 100), // BottomBar payı
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildFeaturedSection(BuildContext context) {
    return SizedBox(
      height: 600, // Ekranın %60-70'ini kaplayan alan
      child: Stack(
        children: [
          // A. Arkaplan Resmi
          Positioned.fill(
            child: Image.network(
              "https://picsum.photos/800/1200?random=99", // Dikey poster formatı
              fit: BoxFit.cover,
            ),
          ),

          // B. Gradient (Resimden siyaha geçiş)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Üst kısım hafif karanlık
                    Colors.transparent,
                    _backgroundColor.withOpacity(0.8), // Alt kısım tam siyah
                    _backgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // C. Üst Menü (Floating Header)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderText("Dersler"),
                _buildHeaderText("Seriler", isActive: true), // Seçili olan
                _buildHeaderText("Canlı Yayın"),
                _buildHeaderText("Kategoriler", hasIcon: true),
              ],
            ),
          ),

          // D. Vitrin İçeriği (Başlık ve Buton)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Etiketler
                Text(
                  "Nörobiyoloji • 3 Sezon • 4K",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                
                // Ana Başlık (Görseldeki Shang-Chi yazısı gibi büyük)
                Text(
                  "THE HUMAN BRAIN",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel( // Sinematik bir font
                    color: _accentColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: [
                      const Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5))
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Watch Now Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VideoPlayerScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: Text(
                    "Derse Başla",
                    style: GoogleFonts.poppins(
                      color: Colors.black, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Alt Aksiyonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionColumn(Icons.add, "Listeme Ekle"),
                    const SizedBox(width: 40),
                    _buildActionColumn(Icons.info_outline, "Detaylar"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {bool isActive = false, bool hasIcon = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            shadows: [const Shadow(color: Colors.black, blurRadius: 5)],
          ),
        ),
        if (hasIcon) const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 16),
      ],
    );
  }

  Widget _buildActionColumn(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Tümü",
            style: GoogleFonts.poppins(color: _accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList({required double height, required double width, bool isWide = false, bool showTag = false}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VideoPlayerScreen()),
              );
            },
            child: Container(
            width: width,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resim Alanı
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          isWide 
                            ? "https://picsum.photos/400/250?random=${index + 100}" 
                            : "https://picsum.photos/200/300?random=${index + 200}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      
                      // "New" veya "Free" Etiketi (Referans görseldeki gibi)
                      if (showTag && index % 2 == 0) 
                        Positioned(
                          top: 8,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: const Text(
                              "YENİ",
                              style: TextStyle(
                                color: Colors.black, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                      // Play iconu (Sadece geniş kartlarda ortada dursun)
                      if (isWide)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // İçerik Başlığı (Sadece geniş kartlarda)
                if (isWide)
                   Text(
                    "Bölüm ${index + 1}: Frontal Lob",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                  ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}