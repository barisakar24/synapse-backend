class Quiz {
  final String id;
  final String title;
  final String description;
  final String image;
  final String level; // "Kolay", "Orta", "Zor" vb.
  final int xp; // Bu quizi bitirince kazanılacak puan
  final List<Question> questions;

  Quiz({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.image, 
    required this.level,
    required this.xp,
    required this.questions
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      level: json['level'] ?? 'Orta',
      xp: json['xp'] ?? 100,
      questions: (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class Question {
  final String text;
  final String? imageUrl; // Resimli soru olabilir
  final List<String> options;
  final int answerIndex;

  Question({required this.text, this.imageUrl, required this.options, required this.answerIndex});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['question'],
      imageUrl: json['image_url'],
      options: List<String>.from(json['options']),
      answerIndex: json['answer_index'],
    );
  }
}