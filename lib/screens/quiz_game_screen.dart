import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_model.dart';

class QuizGameScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizGameScreen({super.key, required this.quiz});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  int _score = 0;

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return; // Zaten cevaplandıysa işlem yapma

    setState(() {
      _selectedOption = selectedIndex;
      _isAnswered = true;
      if (selectedIndex == widget.quiz.questions[_currentIndex].answerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 60),
            const SizedBox(height: 20),
            Text("Tebrikler!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "Skorun: $_score / ${widget.quiz.questions.length}",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Sheet'i kapat
                  Navigator.pop(context); // Listeye dön
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Listeye Dön", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.quiz.questions.length,
          backgroundColor: Colors.grey[800],
          color: const Color(0xFFFFD700),
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Soru Sayacı
            Text(
              "Soru ${_currentIndex + 1}/${widget.quiz.questions.length}",
              style: GoogleFonts.poppins(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Soru Metni
            Text(
              question.text,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Resim (Varsa)
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(question.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
              )
            else
              const Spacer(),

            // Seçenekler
            ...List.generate(question.options.length, (index) {
              return _buildOption(index, question.options[index], question.answerIndex);
            }),

            const SizedBox(height: 20),
            
            // İlerle Butonu (Sadece cevap verildiyse görünür)
            if (_isAnswered)
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentIndex == widget.quiz.questions.length - 1 ? "Sonucu Gör" : "Sonraki Soru",
                    style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text, int correctIndex) {
    bool isSelected = _selectedOption == index;
    bool isCorrect = index == correctIndex;
    
    Color borderColor = Colors.white12;
    Color bgColor = const Color(0xFF1E1E24);
    IconData? icon;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.green.withOpacity(0.2);
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.redAccent;
        bgColor = Colors.red.withOpacity(0.2);
        icon = Icons.cancel;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.blueAccent : borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: Colors.white30),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D...
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),
            if (icon != null) Icon(icon, color: isCorrect ? Colors.greenAccent : Colors.redAccent),
          ],
        ),
      ),
    );
  }
}