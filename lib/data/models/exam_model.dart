class ExamModel {
  final String id;
  final String title; // örn: "Vize 1", "Final", "Quiz 1"
  final double? score; // 0 - 100
  final String? letterGrade; // AA, BA, BB, CB, CC, DC, DD, FD, FF
  final double weight; // Yüzdelik etki (örn: 40 for %40)
  final DateTime date;
  final String? notes;

  ExamModel({
    required this.id,
    required this.title,
    this.score,
    this.letterGrade,
    this.weight = 0.0,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'score': score,
      'letterGrade': letterGrade,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      letterGrade: json['letterGrade'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 0.0,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  ExamModel copyWith({
    String? id,
    String? title,
    double? score,
    String? letterGrade,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return ExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      score: score ?? this.score,
      letterGrade: letterGrade ?? this.letterGrade,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

