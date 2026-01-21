import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'layout_scaffold.dart'; // Bu dosyanın aynı klasörde (lib/) olduğundan emin olun
import 'screens/login_screen.dart';

void main() {
  runApp(const NeuroscienceApp());
}

class NeuroscienceApp extends StatelessWidget {
  const NeuroscienceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synapse', // Uygulama adı
      debugShowCheckedModeBanner: false,
      
      // Sadece koyu tema kullanılsın
      themeMode: ThemeMode.dark,
      
      // Koyu Tema Ayarları
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1115), // Belirlediğimiz koyu zemin
        primaryColor: const Color(0xFF2962FF), // Elektrik mavisi ana renk
        
        // AppBar Teması
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1115),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Font Ayarları (Tüm uygulama Poppins kullanacak)
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),

        // Renk Şeması
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2962FF),   // Mavi vurgu
          secondary: Color(0xFFFFD700), // Atlas ve Haberlerde kullandığımız Sarı/Gold vurgu
          surface: Color(0xFF1E1E24),   // Kart renkleri
          onSurface: Colors.white,
        ),
      ),
      
      // Başlangıç Sayfası (Navigasyon İskeleti)
      home: const LoginScreen(),
    );
  }
}