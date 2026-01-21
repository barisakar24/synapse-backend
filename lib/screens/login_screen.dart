import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../layout_scaffold.dart'; // Giriş başarılı olursa ana sayfaya yönlendirmek için

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // Renk Paleti (Deep Navy & Electric Blue)
  final Color _midnightBlue = const Color(0xFF0A0E21); // Çok koyu lacivert zemin
  final Color _accentBlue = const Color(0xFF2962FF); // Elektrik mavisi vurgu
  final Color _inputFillColor = const Color(0xFF1A1F38).withOpacity(0.7); // Yarı saydam giriş kutusu

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Videoyu başlatma
    _videoController = VideoPlayerController.asset("assets/synapse_bg.mp4")
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setLooping(true); // Sürekli dönsün
        _videoController.setVolume(0.0); // Ses kapalı
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş Yapma Fonksiyonu (Simülasyon)
  void _handleLogin() {
    // Burada Firebase Auth işlemleri olacak.
    // Şimdilik direkt ana sayfaya atıyoruz.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LayoutScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _midnightBlue,
      // Klavye açılınca ekranın bozulmaması için
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // KATMAN 1: Arka Plan Videosu
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(color: _midnightBlue), // Video yüklenirken düz renk

          // KATMAN 2: Karartma Gradyanı (Videonun üstüne sinematik gölge)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _midnightBlue.withOpacity(0.6), // Üst kısım daha şeffaf
                  _midnightBlue.withOpacity(0.8),
                  _midnightBlue, // Alt kısım tamamen koyu
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // KATMAN 3: Form İçeriği
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo ve Başlık
                  Icon(Icons.grain, color: _accentBlue, size: 60), // Geçici nöron ikonu
                  const SizedBox(height: 20),
                  Text(
                    "SYNAPSE",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),
                  Text(
                    "Bilginin Nöral Ağına Bağlan",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const Spacer(flex: 3),

                  // Giriş Alanları
                  _buildElegantTextField(
                    controller: _emailController,
                    hintText: "E-posta Adresi",
                    icon: CupertinoIcons.mail,
                  ),
                  const SizedBox(height: 20),
                  _buildElegantTextField(
                    controller: _passwordController,
                    hintText: "Şifre",
                    icon: CupertinoIcons.lock,
                    isPassword: true,
                  ),
                  
                  const SizedBox(height: 15),
                  // Şifremi Unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Şifremi Unuttum?",
                        style: GoogleFonts.poppins(color: _accentBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Giriş Yap Butonu
                  _buildPrimaryButton(text: "GİRİŞ YAP", onTap: _handleLogin),
                  
                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("veya", style: GoogleFonts.poppins(color: Colors.white54))),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ]),
                  const SizedBox(height: 20),

                  // Google ile Giriş Butonu
                  _buildGoogleButton(),

                  const Spacer(flex: 4),

                  // Kayıt Ol Alt Metni
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hesabın yok mu?", style: GoogleFonts.poppins(color: Colors.white70)),
                      TextButton(
                        onPressed: () {
                          // Kayıt Ol sayfasına yönlendirme
                        },
                        child: Text(
                          "Kayıt Ol",
                          style: GoogleFonts.poppins(color: _accentBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR (Tasarım Detayları) ---

  // 1. Elegant Input Alanı
  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          prefixIcon: Icon(icon, color: _accentBlue.withOpacity(0.7), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // 2. Ana Buton (Gradient Efektli)
  Widget _buildPrimaryButton({required String text, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_accentBlue, const Color(0xFF00BFA5)], // Maviden turkuaza geçiş
        ),
        boxShadow: [
          BoxShadow(color: _accentBlue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }

  // 3. Google Butonu (GÜNCELLENMİŞ VERSİYON)
  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Google Sign-In işlemleri
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        // Logo internetten çekilecek, assets hatası vermeyecek
        icon: Image.network(
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png",
          height: 24,
        ),
        label: Text(
          "Google ile Devam Et",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

// Google Iconu için geçici çözüm (Eğer ionicons paketi yoksa)
class Ionicons {
  static const IconData logo_google = IconData(0xe900, fontFamily: 'Ionicons'); // Bu sadece örnek, çalışmayabilir.
  // Eğer Google iconu çıkmazsa yukarıdaki _buildGoogleButton içindeki icon satırını şöyle değiştir:
  // icon: const Icon(Icons.g_mobiledata, color: Colors.black, size: 30), 
}