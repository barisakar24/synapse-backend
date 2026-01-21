import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';
import 'quiz_game_screen.dart'; // Oyun ekranını birazdan yazacağız

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  // --- VERİ YÜKLEME MANTIĞI ---
  Future<void> _loadQuizData() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // 1. Admin panelinden yüklenmiş veri var mı?
      String? jsonString = prefs.getString('quiz_data_custom');

      // 2. Yoksa Assets'teki varsayılan dosyayı oku
      if (jsonString == null || jsonString.isEmpty) {
        jsonString = await rootBundle.loadString('assets/quiz_data.json');
      }

      final List<dynamic> data = json.decode(jsonString!);
      setState(() {
        _quizzes = data.map((item) => Quiz.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Brain Challenge", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          // XP Rozeti
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 8)],
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text("1250 XP", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _quizzes.length,
              itemBuilder: (context, index) {
                return _buildQuizCard(_quizzes[index]);
              },
            ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizGameScreen(quiz: quiz)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(quiz.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // Gradyan Kaplama
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
            
            // İçerik
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Üst Etiketler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTag(quiz.level, Colors.blueAccent),
                      _buildTag("+${quiz.xp} XP", const Color(0xFFFFD700), textColor: Colors.black),
                    ],
                  ),
                  
                  // Alt Bilgiler
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.quiz, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "${quiz.questions.length} Soru",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.timer, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "~${quiz.questions.length * 1} dk",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Play Butonu (Floating)
            Positioned(
              bottom: 20,
              right: 20,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}