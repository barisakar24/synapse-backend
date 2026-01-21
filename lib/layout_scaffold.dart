import 'dart:ui'; // Blur efekti için gerekli
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/news_screen.dart';
import 'screens/education_screen.dart';
import 'screens/atlas_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/profile_screen.dart'; // <-- 1. IMPORT ET

class LayoutScaffold extends StatefulWidget {
  const LayoutScaffold({super.key});

  @override
  State<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends State<LayoutScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const NewsScreen(),      // 0: Haber
    const EducationScreen(), // 1: Eğitim
    const QuizScreen(),      // 2: Quiz
    const AtlasScreen(),     // 3: Atlas
    const ProfileScreen(),   // <-- 2. BURAYI GÜNCELLE
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // İçeriğin navigasyon barın arkasına uzanmasını sağlar (Blur için)
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115).withOpacity(0.85), // Yarı saydam koyu zemin
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Yuvarlatılmış köşeler
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5), // İnce çerçeve
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Daha güçlü blur
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Container rengini kullanması için
              elevation: 0,
              iconSize: 28, // İkonları biraz büyüttük
              selectedItemColor: const Color(0xFFFFD700), // Seçili ikon Altın Sarısı (Gold)
              unselectedItemColor: Colors.grey.shade600,
              showUnselectedLabels: true,
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.news), activeIcon: Icon(CupertinoIcons.news_solid), label: 'Haberler'),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.play_circle), activeIcon: Icon(CupertinoIcons.play_circle_fill), label: 'Dersler'),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.sparkles), activeIcon: Icon(CupertinoIcons.sparkles), label: 'Quiz'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.grain), activeIcon: Icon(Icons.grain), label: 'Atlas'),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person_crop_circle),
                    activeIcon: Icon(CupertinoIcons.person_crop_circle_fill),
                    label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}