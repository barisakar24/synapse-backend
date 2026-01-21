import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final Color _accentColor = const Color(0xFFFFD700); // Gold/Sarı tema
  final Color _backgroundColor = const Color(0xFF000000);
  final Color _surfaceColor = const Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VİDEO OYNATICI ALANI (PLAYER AREA)
            _buildVideoPlayerArea(),

            // 2. DETAYLAR VE LİSTE (SCROLLABLE)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Text(
                            "Bölüm 1: Nöroplastisiteye Giriş",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Meta Veriler (Yıl, Süre, Kalite)
                          Row(
                            children: [
                              const Text("2026", style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                color: Colors.grey[800],
                                child: const Text("18+", style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              const SizedBox(width: 10),
                              const Text("45dk", style: TextStyle(color: Colors.grey)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text("HD", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Play / Download Butonları
                          _buildMainActionButtons(),

                          const SizedBox(height: 16),

                          // Açıklama Metni
                          Text(
                            "Bu derste beynin yapısal ve işlevsel olarak nasıl değişebildiğini, öğrenme süreçlerinin nöronal temellerini ve sinaptik güçlenmeyi (LTP) inceleyeceğiz.",
                            style: const TextStyle(color: Colors.white70, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 24),

                          // Aksiyon İkonları (Listem, Puanla, Paylaş)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildActionIcon(Icons.add, "Listem"),
                              const SizedBox(width: 30),
                              _buildActionIcon(Icons.thumb_up_alt_outlined, "Beğen"),
                              const SizedBox(width: 30),
                              _buildActionIcon(Icons.share, "Paylaş"),
                              const SizedBox(width: 30),
                              _buildActionIcon(Icons.download_for_offline_outlined, "İndir"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white10),

                    // Sekme Başlığı (Bölümler / Benzerleri)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _buildTabTitle("Bölümler", isActive: true),
                          const SizedBox(width: 20),
                          _buildTabTitle("Benzer İçerikler", isActive: false),
                        ],
                      ),
                    ),

                    // Bölüm Listesi
                    _buildEpisodeList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildVideoPlayerArea() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          // Arkaplan Resmi (Video Thumbnail)
          Image.network(
            "https://picsum.photos/800/450?random=55",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Karanlık Katman
          Container(color: Colors.black.withOpacity(0.4)),

          // Geri Butonu
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Play Butonu (Ortada)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
          ),

          // Alt İlerleme Çubuğu (Fake Progress)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Süre Bilgisi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("12:45", style: TextStyle(color: Colors.white, fontSize: 10)),
                      const Text("45:00", style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Progress Bar
                LinearProgressIndicator(
                  value: 0.3, // %30 izlenmiş
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow, color: Colors.black),
        label: const Text("Oynat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildTabTitle(String title, {required bool isActive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 30,
            color: _accentColor, // Aktif sekme çizgisi
          ),
      ],
    );
  }

  Widget _buildEpisodeList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll dışta zaten var
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: (index == 0) ? _surfaceColor : Colors.transparent, // İlk öğe (çalan) hafif gri
          child: Row(
            children: [
              // Küçük Resim
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://picsum.photos/150/90?random=${index + 50}",
                      width: 120,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (index == 0) // Sadece çalan videoda play ikonu olsun
                    const Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
                ],
              ),
              const SizedBox(width: 12),
              
              // Metin Bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bölüm ${index + 1}",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sinaptik İletim ve Reseptörler",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text("45 dk", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              
              // İndir Butonu
              IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}