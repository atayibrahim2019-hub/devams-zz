class ScheduleItemModel {
  final String id;
  final int weekday; // 1 = Pazartesi ... 7 = Pazar
  final String courseName; // örn: "Matematik", "Fizik"
  final String startTime; // örn: "09:00"
  final String endTime; // örn: "12:00"
  final String location; // örn: "Derslik A101"
  final int lessonCount; // Ders saati / blok sayısı (örn: 1 veya 2)
  final String note;

  const ScheduleItemModel({
    required this.id,
    required this.weekday,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.lessonCount = 1,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekday': weekday,
      'courseName': courseName,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'lessonCount': lessonCount,
      'note': note,
    };
  }

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      id: json['id'] as String? ?? '',
      weekday: json['weekday'] as int? ?? 1,
      courseName: json['courseName'] as String? ?? 'Ders',
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '12:00',
      location: json['location'] as String? ?? '',
      lessonCount: json['lessonCount'] as int? ?? 1,
      note: json['note'] as String? ?? '',
    );
  }

  ScheduleItemModel copyWith({
    String? id,
    int? weekday,
    String? courseName,
    String? startTime,
    String? endTime,
    String? location,
    int? lessonCount,
    String? note,
  }) {
    return ScheduleItemModel(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      courseName: courseName ?? this.courseName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      lessonCount: lessonCount ?? this.lessonCount,
      note: note ?? this.note,
    );
  }
}

