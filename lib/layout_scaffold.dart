import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F1115),
          selectedItemColor: const Color(0xFF2962FF),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.news), label: 'Haber'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.play_rectangle), label: 'Eğitim'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.question_circle), label: 'Quiz'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Atlas'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}