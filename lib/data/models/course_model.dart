import 'attendance_log_model.dart';
import 'exam_model.dart';
import 'schedule_item_model.dart';

class CourseModel {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final int maxAllowedAbsence; // İzin verilen maksimum devamsızlık (oturum/saat)
  final List<int> classDays; // 1 = Pazartesi ... 7 = Pazar
  final String classStartTime; // örn: "08:30"
  final String classEndTime; // örn: "12:20"
  final int smartWindowDeadlineHour; // Akıllı pencere bitiş saati (varsayılan 18:00)
  
  // Ek sayaç düzeltmeleri (manuel hızlı + / - için opsiyonel)
  final int manualAttendedOffset;
  final int manualAbsentOffset;

  final Map<String, AttendanceLogModel> attendanceLogs;
  final List<ExamModel> exams;
  final List<ScheduleItemModel> weeklySchedule; // Haftalık ders programı slotları
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.name,
    this.code = '',
    this.instructor = '',
    this.maxAllowedAbsence = 4,
    this.classDays = const [1],
    this.classStartTime = '09:00',
    this.classEndTime = '12:00',
    this.smartWindowDeadlineHour = 18,
    this.manualAttendedOffset = 0,
    this.manualAbsentOffset = 0,
    Map<String, AttendanceLogModel>? attendanceLogs,
    List<ExamModel>? exams,
    List<ScheduleItemModel>? weeklySchedule,
    DateTime? createdAt,
  })  : attendanceLogs = attendanceLogs ?? {},
        exams = exams ?? [],
        weeklySchedule = weeklySchedule ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Belirli bir güne ait ders programı slotları
  List<ScheduleItemModel> getScheduleForWeekday(int weekday) {
    return weeklySchedule.where((s) => s.weekday == weekday).toList();
  }

  /// Belirli bir gündeki toplam ders sayısı
  int getLessonCountForWeekday(int weekday) {
    final list = getScheduleForWeekday(weekday);
    if (list.isEmpty) return 1; // En az 1 ders varsay
    return list.fold<int>(0, (acc, item) => acc + item.lessonCount);
  }

  /// Girilen toplam ders sayısı (loglardaki saat/ders toplamı)
  int get attendedCount {
    int logAttended = attendanceLogs.values
        .where((log) => log.status == AttendanceStatus.attended)
        .fold(0, (acc, log) => acc + log.lessonsCount);
    return logAttended + manualAttendedOffset;
  }

  /// Girilmeyen (Devamsızlık) toplam ders sayısı (loglardaki saat/ders toplamı)
  int get absentCount {
    int logAbsent = attendanceLogs.values
        .where((log) => log.status == AttendanceStatus.absent)
        .fold(0, (acc, log) => acc + log.lessonsCount);
    return logAbsent + manualAbsentOffset;
  }

  /// Toplam işlenen ders sayısı (Girilen + Girilmeyen)
  int get totalSessionsCount {
    return attendedCount + absentCount;
  }

  /// Kalan devamsızlık hakkı
  int get remainingAbsenceAllowed {
    final remaining = maxAllowedAbsence - absentCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Devamsızlık oranı yüzdesi (%)
  double get absencePercentage {
    if (totalSessionsCount == 0) return 0.0;
    return (absentCount / totalSessionsCount) * 100;
  }

  /// Katılım oranı yüzdesi (%)
  double get attendancePercentage {
    if (totalSessionsCount == 0) return 100.0;
    return (attendedCount / totalSessionsCount) * 100;
  }

  /// Kritik devamsızlık eşiğinde mi? (Kalan hak <= 2)
  bool get isCriticalAttendance {
    return remainingAbsenceAllowed <= 2 && maxAllowedAbsence > 0;
  }

  /// Devamsızlıktan kaldı mı?
  bool get isFailedByAbsence {
    return absentCount > maxAllowedAbsence && maxAllowedAbsence > 0;
  }

  /// Ağırlıklı genel not ortalaması (varsa)
  double? get calculatedAverage {
    final scoredExams = exams.where((e) => e.score != null).toList();
    if (scoredExams.isEmpty) return null;

    double totalWeight = 0;
    double weightedSum = 0;

    for (var exam in scoredExams) {
      if (exam.weight > 0) {
        weightedSum += (exam.score! * exam.weight);
        totalWeight += exam.weight;
      }
    }

    if (totalWeight > 0) {
      return weightedSum / totalWeight;
    }

    // Ağırlık belirtilmemişse düz aritmetik ortalama
    double sum = scoredExams.fold(0.0, (prev, e) => prev + e.score!);
    return sum / scoredExams.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'maxAllowedAbsence': maxAllowedAbsence,
      'classDays': classDays,
      'classStartTime': classStartTime,
      'classEndTime': classEndTime,
      'smartWindowDeadlineHour': smartWindowDeadlineHour,
      'manualAttendedOffset': manualAttendedOffset,
      'manualAbsentOffset': manualAbsentOffset,
      'attendanceLogs': attendanceLogs.map((k, v) => MapEntry(k, v.toJson())),
      'exams': exams.map((e) => e.toJson()).toList(),
      'weeklySchedule': weeklySchedule.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    Map<String, AttendanceLogModel> logs = {};
    if (json['attendanceLogs'] != null) {
      final logsMap = json['attendanceLogs'] as Map<String, dynamic>;
      logsMap.forEach((key, val) {
        logs[key] = AttendanceLogModel.fromJson(val as Map<String, dynamic>);
      });
    }

    List<ExamModel> examList = [];
    if (json['exams'] != null) {
      examList = (json['exams'] as List)
          .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<ScheduleItemModel> schedList = [];
    if (json['weeklySchedule'] != null) {
      schedList = (json['weeklySchedule'] as List)
          .map((e) => ScheduleItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      schedList = _defaultSchedule();
    }

    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      maxAllowedAbsence: json['maxAllowedAbsence'] as int? ?? 8,
      classDays: json['classDays'] != null
          ? List<int>.from(json['classDays'])
          : [1, 3],
      classStartTime: json['classStartTime'] as String? ?? '08:30',
      classEndTime: json['classEndTime'] as String? ?? '17:20',
      smartWindowDeadlineHour: json['smartWindowDeadlineHour'] as int? ?? 18,
      manualAttendedOffset: json['manualAttendedOffset'] as int? ?? 0,
      manualAbsentOffset: json['manualAbsentOffset'] as int? ?? 0,
      attendanceLogs: logs,
      exams: examList,
      weeklySchedule: schedList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    int? maxAllowedAbsence,
    List<int>? classDays,
    String? classStartTime,
    String? classEndTime,
    int? smartWindowDeadlineHour,
    int? manualAttendedOffset,
    int? manualAbsentOffset,
    Map<String, AttendanceLogModel>? attendanceLogs,
    List<ExamModel>? exams,
    List<ScheduleItemModel>? weeklySchedule,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      maxAllowedAbsence: maxAllowedAbsence ?? this.maxAllowedAbsence,
      classDays: classDays ?? this.classDays,
      classStartTime: classStartTime ?? this.classStartTime,
      classEndTime: classEndTime ?? this.classEndTime,
      smartWindowDeadlineHour:
          smartWindowDeadlineHour ?? this.smartWindowDeadlineHour,
      manualAttendedOffset: manualAttendedOffset ?? this.manualAttendedOffset,
      manualAbsentOffset: manualAbsentOffset ?? this.manualAbsentOffset,
      attendanceLogs: attendanceLogs ?? this.attendanceLogs,
      exams: exams ?? this.exams,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
