import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- SİMÜLASYON DEĞİŞKENLERİ ---
  // Gerçek uygulamada burası Firebase Auth'dan gelecek
  bool _isLoggedIn = false; 
  String _userName = "Misafir Kullanıcı";
  String _userEmail = "Giriş yapılmadı";
  String? _photoUrl; // Null ise anonim ikon gösterir

  final Color _backgroundColor = const Color(0xFF0F1115);
  final Color _cardColor = const Color(0xFF1E1E24);
  final Color _accentColor = const Color(0xFF2962FF); // Elektrik Mavisi
  final Color _goldColor = const Color(0xFFFFD700);   // XP Altın Rengi

  // Giriş Yapma Simülasyonu
  void _handleGoogleSignIn() {
    // Burada ileride "await _googleSignIn.signIn()" çalışacak
    setState(() {
      _isLoggedIn = true;
      _userName = "Barış Akar";
      _userEmail = "baris.akar@synapse.com";
      _photoUrl = "https://randomuser.me/api/portraits/men/32.jpg"; // Google Fotoğrafı Örneği
    });
  }

  // Çıkış Yapma Simülasyonu
  void _handleLogout() {
    // Giriş ekranına dön ve geçmişi temizle
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // 1. ÜST PROFİL KARTI (HEADER)
            _buildProfileHeader(),

            // 2. İSTATİSTİKLER (Sadece giriş yapınca anlamlı ama şimdilik gösterelim)
            if (_isLoggedIn) _buildStatsSection(),

            const SizedBox(height: 20),

            // 3. MENÜ LİSTESİ
            _buildSectionTitle("Hesap Ayarları"),
            _buildMenuItem(icon: CupertinoIcons.person, title: "Kişisel Bilgiler", onTap: () {}),
            _buildMenuItem(icon: CupertinoIcons.bell, title: "Bildirimler", badge: "2"),
            _buildMenuItem(icon: CupertinoIcons.eye, title: "Görünüm (Dark Mode)", isSwitch: true),

            _buildSectionTitle("Destek & Hakkında"),
            _buildMenuItem(icon: CupertinoIcons.question_circle, title: "Yardım Merkezi", onTap: () {}),
            _buildMenuItem(icon: CupertinoIcons.info, title: "Uygulama Hakkında", onTap: () {}),

            const SizedBox(height: 30),

            // 4. ÇIKIŞ BUTONU (Sadece giriş yapıldıysa)
            if (_isLoggedIn)
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text("Hesaptan Çıkış Yap", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
              
            const SizedBox(height: 50), // BottomBar payı
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          // Profil Fotoğrafı
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isLoggedIn ? _accentColor : Colors.grey, width: 3),
              boxShadow: [BoxShadow(color: (_isLoggedIn ? _accentColor : Colors.grey).withOpacity(0.4), blurRadius: 20)],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _photoUrl == null
                  ? const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.white54)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          
          // İsim ve Email
          Text(
            _userName,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            _userEmail,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          
          const SizedBox(height: 20),

          // Giriş Yap Butonu (Eğer giriş yapılmadıysa)
          if (!_isLoggedIn)
            ElevatedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png", height: 24),
              label: Text("Google ile Giriş Yap", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            
           if (_isLoggedIn)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: _goldColor.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(color: _goldColor.withOpacity(0.3))
               ),
               child: Text("PRO ÜYE", style: TextStyle(color: _goldColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
             )
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _statCard("Seviye", "5", CupertinoIcons.bolt_fill, Colors.orange),
          const SizedBox(width: 15),
          _statCard("Toplam XP", "1250", Icons.stars, _goldColor),
          const SizedBox(width: 15),
          _statCard("Sıralama", "#42", CupertinoIcons.chart_bar_alt_fill, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(color: _accentColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, String? badge, bool isSwitch = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        trailing: isSwitch
            ? Switch(
                value: true, // Şimdilik sabit true
                onChanged: (val) {},
                activeColor: _accentColor,
              )
            : (badge != null
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                : const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 16)),
      ),
    );
  }
}