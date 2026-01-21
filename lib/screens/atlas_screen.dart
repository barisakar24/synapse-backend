import 'dart:async';
import 'dart:convert';
import 'dart:math'; // min fonksiyonu için
import 'dart:ui'; // Blur efekti için
import 'dart:js' as js; // 👈 WEB İÇİN GEREKLİ KÜTÜPHANE
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:http/http.dart' as http;

class AtlasScreen extends StatefulWidget {
  const AtlasScreen({super.key});

  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
  // --- AYARLAR VE DEĞİŞKENLER ---
  String aktifModelYolu = 'assets/beyin_final_v5.glb';
  Key modelKey = UniqueKey();
  
  // API Key
  final String openAiApiKey = '';

  // UI Renkleri
  final Color _accentColor = const Color(0xFFFFD700); // Gold/Sarı
  final Color _backgroundColor = const Color(0xFF0F1115); // Synapse Dark
  
  // Durum Değişkenleri
  String secilenBolgeIsmi = "";
  String aiYaniti = "";
  bool aiYukleniyor = false;
  StateSetter? _panelGuncelleyici;

  // Quiz Modu
  bool quizModuAktif = false;
  String quizHedef = "";
  int quizPuan = 0;
  String quizMesaj = "";
  Color quizMesajRengi = Colors.white;

  final List<String> tumBeyinBolgeleri = [
    "Frontal Lobe", "Temporal Lobe", "Parietal Lobe", "Occipital Lobe",
    "Cerebellum", "Brain Stem", "Precentral Gyrus", "Postcentral Gyrus",
    "Superior Temporal Gyrus", "Middle Temporal Gyrus", "Inferior Temporal Gyrus",
    "Supramarginal Gyrus", "Angular Gyrus", "Broca's Area", "Wernicke's Area",
    "Insula", "Cingulate Gyrus", "Hippocampus", "Amygdala", "Thalamus",
    "Putamen", "Caudate Nucleus", "Pallidum", "Corpus Callosum",
    "Lateral Ventricle", "3rd Ventricle", "4th Ventricle",
    "Olfactory Bulb", "Optic Chiasm", "Pons", "Medulla Oblongata"
  ];

  @override
  void initState() {
    super.initState();
    // 👇 JavaScript'ten gelen tıklamayı dinleyen köprü
    try {
      js.context['tiklamaYakala'] = js.allowInterop((String mesaj) {
        _tiklamaIslemleri(mesaj);
      });
    } catch (e) {
      debugPrint("Web interop hatası (Mobilde çalışmaz): $e");
    }
  }

  // --- YAPAY ZEKA ANALİZİ ---
  Future<void> _beyniAnalizEt(String bolgeIsmi) async {
    setState(() {
      aiYaniti = "";
      aiYukleniyor = true;
    });
    _panelGuncelleyici?.call(() {});

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final prompt = "Sen uzman bir nörologsun. '$bolgeIsmi' adlı beyin bölgesini analiz et. "
          "1. Temel görevi nedir? "
          "2. Bu bölge hasar görürse ne olur? "
          "3. Hakkında ilginç bir kısa bilgi ver. "
          "Cevabı sadece bu 3 madde halinde, kısa ve öz, Türkçe olarak ver.";

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "Sen yardımcı bir nöroloji asistanısın."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final metin = data['choices'][0]['message']['content'];
        
        if (mounted) {
          setState(() {
            aiYaniti = metin;
            aiYukleniyor = false;
          });
          _panelGuncelleyici?.call(() {});
        }
      } else {
        throw Exception("API Hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Hata: $e");
      if (mounted) {
        setState(() {
          aiYaniti = "Bağlantı hatası oluştu. Lütfen tekrar deneyin.";
          aiYukleniyor = false;
        });
        _panelGuncelleyici?.call(() {});
      }
    }
  }

  // --- TIKLAMA MANTIĞI ---
  void _tiklamaIslemleri(String gelenIsim) {
    if (gelenIsim.isEmpty || gelenIsim == "Boşluk" || gelenIsim == "undefined") return;

    String temizIsim = "";

    // Gelen veri JSON mu diye kontrol et (Koordinatlı veri)
    if (gelenIsim.trim().startsWith('{')) {
      try {
        final Map<String, dynamic> veri = jsonDecode(gelenIsim);
        temizIsim = veri['isim'] ?? "";
      } catch (e) {
        debugPrint("JSON ayrıştırma hatası: $e");
        return;
      }
    } else {
      // Eski usül sadece isim geldiyse
      temizIsim = gelenIsim.replaceAll('"', '').trim();
    }

    if (quizModuAktif) {
      // Quiz Mantığı
      if (temizIsim.toLowerCase().contains(quizHedef.toLowerCase()) || 
          quizHedef.toLowerCase().contains(temizIsim.toLowerCase())) {
        setState(() {
          quizPuan += 10;
          quizMesaj = "DOĞRU! 🎉";
          quizMesajRengi = Colors.greenAccent;
          Future.delayed(const Duration(milliseconds: 1500), _yeniSoruSor);
        });
      } else {
        setState(() {
          quizMesaj = "Yanlış: $temizIsim";
          quizMesajRengi = Colors.redAccent;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if(mounted && quizModuAktif) {
             setState(() {
               quizMesaj = "HEDEF: $quizHedef";
               quizMesajRengi = _accentColor;
             });
          }
        });
      }
    } else {
      // Normal Mod Mantığı
      setState(() {
        secilenBolgeIsmi = temizIsim;
        aiYaniti = ""; // Önceki analizi temizle
        aiYukleniyor = false;
        // _detayPaneliniAc(); // ARTIK OTOMATİK AÇMIYORUZ
      });
    }
  }

  // --- UI WIDGETLARI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: quizModuAktif ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context), 
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            "BEYİN ATLASI",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search, color: Colors.white),
            onPressed: _aramaBaslat,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. 3D MODEL GÖRÜNTÜLEYİCİ
          ModelViewer(
            key: modelKey,
            src: aktifModelYolu,
            alt: "3D Brain Model",
            backgroundColor: _backgroundColor,
            cameraControls: true,
            autoRotate: false,
            cameraOrbit: "0deg 75deg 105%",
            fieldOfView: "30deg",
            shadowIntensity: 1.0,
          ),

          // 1.5 SEÇİM KARTI (Üst Bölümde Sabit)
          if (secilenBolgeIsmi.isNotEmpty && !quizModuAktif) _buildSelectionCard(),

          // 2. QUIZ HUD (Sadece Quiz Modunda)
          if (quizModuAktif) _buildQuizHUD(),

          // 3. MODEL DEĞİŞTİRİCİ (ALT MENÜ)
          if (!quizModuAktif) _buildBottomControls(),

          // 4. QUIZ BAŞLAT BUTONU
          if (!quizModuAktif && secilenBolgeIsmi.isEmpty) // Seçim varken gizle
            Positioned(
              top: 100,
              left: 20,
              child: GestureDetector(
                onTap: _quizBaslat,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.4), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gamepad, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text("Quiz Modu", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

          // 5. BÖLGELER LİSTESİ BUTONU (Sağ Üst)
          if (!quizModuAktif && secilenBolgeIsmi.isEmpty) // Seçim varken gizle
            Positioned(
              top: 100,
              right: 20,
              child: GestureDetector(
                onTap: _bolgeListesiniAc,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Text("Bölgeler", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.list, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- ALT WIDGET PARÇALARI ---
  
  Widget _buildSelectionCard() {
    return Positioned(
      top: 100, // Butonların olduğu hiza
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentColor.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      secilenBolgeIsmi,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => setState(() => secilenBolgeIsmi = ""),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _beyniAnalizEt(secilenBolgeIsmi); // Analizi başlat
                      _detayPaneliniAc(); // Ve detay panelini aç
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.black),
                    label: Text("Yapay Zeka ile Analiz Et", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHUD() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor),
                ),
                child: Text(
                  "PUAN: $quizPuan",
                  style: GoogleFonts.poppins(color: _accentColor, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _quizBitir,
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.8)),
              )
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: quizMesajRengi, width: 2),
                ),
                child: Column(
                  children: [
                    Text("BULMAN GEREKEN BÖLGE", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(
                      quizModuAktif ? (quizMesaj.contains("HEDEF") ? quizHedef : quizMesaj) : "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: quizMesajRengi,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _modelSelectorBtn("Sol Lob", "assets/sol.glb"),
                _modelSelectorBtn("Tüm Beyin", "assets/beyin_final_v5.glb"),
                _modelSelectorBtn("Sağ Lob", "assets/sag.glb"),
                _modelSelectorBtn("İç Yapılar", "assets/subcortical.glb"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modelSelectorBtn(String label, String path) {
    bool isSelected = aktifModelYolu == path;
    return GestureDetector(
      onTap: () {
        if (aktifModelYolu != path) {
          setState(() {
            aktifModelYolu = path;
            modelKey = UniqueKey();
            secilenBolgeIsmi = "";
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // --- BÖLGE LİSTESİ PANELİ ---
  void _bolgeListesiniAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Beyin Bölgeleri", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                itemCount: tumBeyinBolgeleri.length,
                itemBuilder: (context, index) {
                  final bolge = tumBeyinBolgeleri[index];
                  return ListTile(
                    title: Text(bolge, style: GoogleFonts.poppins(color: Colors.white70)),
                    trailing: Icon(Icons.arrow_forward_ios, color: _accentColor, size: 14),
                    onTap: () {
                      Navigator.pop(context); // Listeyi kapat
                      _tiklamaIslemleri(bolge); // Seçimi işle
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- DETAY PANELİ ---
  void _detayPaneliniAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            _panelGuncelleyici = setModalState;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(color: _accentColor.withOpacity(0.3), width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            secilenBolgeIsmi,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.auto_awesome, color: _accentColor),
                        )
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Analiz Yapılmadıysa Butonu Göster
                          if (aiYaniti.isEmpty && !aiYukleniyor)
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => _beyniAnalizEt(secilenBolgeIsmi),
                                icon: const Icon(Icons.auto_awesome, color: Colors.black),
                                label: Text("Yapay Zeka ile Analiz Et", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),

                          // 2. Yükleniyorsa
                          if (aiYukleniyor)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                            ))
                          
                          // 3. Yanıt Geldiyse Göster
                          else if (aiYaniti.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Yapay Zeka Analizi",
                                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, letterSpacing: 1),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  aiYaniti,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => _panelGuncelleyici = null);
  }

  // --- FONKSİYONLAR ---
  void _quizBaslat() {
    setState(() {
      quizModuAktif = true;
      quizPuan = 0;
      secilenBolgeIsmi = "";
      _yeniSoruSor();
    });
  }

  void _quizBitir() {
    setState(() {
      quizModuAktif = false;
      quizHedef = "";
    });
  }

  void _yeniSoruSor() {
    if (!quizModuAktif) return;
    setState(() {
      quizHedef = tumBeyinBolgeleri[Random().nextInt(tumBeyinBolgeleri.length)];
      quizMesaj = "HEDEF: $quizHedef";
      quizMesajRengi = _accentColor;
    });
  }

  void _aramaBaslat() async {
    final secilen = await showSearch(
      context: context,
      delegate: BeyinAramaDelegate(bolgeListesi: tumBeyinBolgeleri),
    );
    if (secilen != null && secilen.isNotEmpty) {
       setState(() {
         secilenBolgeIsmi = secilen;
         aiYaniti = ""; // Temizle
         aiYukleniyor = false;
         _detayPaneliniAc();
       });
    }
  }
}

// --- ARAMA DELEGATE ---
class BeyinAramaDelegate extends SearchDelegate<String> {
  final List<String> bolgeListesi;
  BeyinAramaDelegate({required this.bolgeListesi});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F1115), elevation: 0),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => query = "")];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)), onPressed: () => close(context, ""));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final oneriler = query.isEmpty ? [] : bolgeListesi.where((bolge) => bolge.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: oneriler.length,
      itemBuilder: (context, index) {
        final sonuc = oneriler[index];
        return ListTile(
          leading: const Icon(Icons.science, color: Colors.white54),
          title: Text(sonuc, style: GoogleFonts.poppins(color: Colors.white)),
          onTap: () => close(context, sonuc),
        );
      },
    );
  }
}