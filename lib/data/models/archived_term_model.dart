import 'exam_model.dart';

class ArchivedTermModel {
  final String id;
  final String termTitle; // örn: "2024-2025 Güz Dönemi" veya "1. Arşiv Dönemi"
  final DateTime archivedAt;
  final String courseName;
  final String courseCode;
  final int totalSessions;
  final int attendedSessions;
  final int absentSessions;
  final double attendanceRate;
  final List<ExamModel> exams;
  final double? calculatedAverage;

  ArchivedTermModel({
    required this.id,
    required this.termTitle,
    required this.archivedAt,
    required this.courseName,
    required this.courseCode,
    required this.totalSessions,
    required this.attendedSessions,
    required this.absentSessions,
    required this.attendanceRate,
    required this.exams,
    this.calculatedAverage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'termTitle': termTitle,
      'archivedAt': archivedAt.toIso8601String(),
      'courseName': courseName,
      'courseCode': courseCode,
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
      'absentSessions': absentSessions,
      'attendanceRate': attendanceRate,
      'exams': exams.map((e) => e.toJson()).toList(),
      'calculatedAverage': calculatedAverage,
    };
  }

  factory ArchivedTermModel.fromJson(Map<String, dynamic> json) {
    List<ExamModel> examList = [];
    if (json['exams'] != null) {
      examList = (json['exams'] as List)
          .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ArchivedTermModel(
      id: json['id'] as String,
      termTitle: json['termTitle'] as String,
      archivedAt: DateTime.parse(json['archivedAt'] as String),
      courseName: json['courseName'] as String,
      courseCode: json['courseCode'] as String? ?? '',
      totalSessions: json['totalSessions'] as int,
      attendedSessions: json['attendedSessions'] as int,
      absentSessions: json['absentSessions'] as int,
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
      exams: examList,
      calculatedAverage: json['calculatedAverage'] != null
          ? (json['calculatedAverage'] as num).toDouble()
          : null,
    );
  }
}

