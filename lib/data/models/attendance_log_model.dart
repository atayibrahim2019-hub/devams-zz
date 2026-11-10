enum AttendanceStatus {
  attended, // Derse Girildi
  absent,   // Derse Gitmedi / Devamsızlık
}

class AttendanceLogModel {
  final String dateKey; // 'yyyy-MM-dd'
  final AttendanceStatus status;
  final bool isAutoAssigned; // Otomatik sistem tarafından mı atandı?
  final bool isRetroactivelyCorrected; // Düzeltildi mi?
  final DateTime updatedAt;
  final int lessonsCount; // O gün kaç ders / saat devamsızlık yapıldı
  final bool isFullDay; // Gün olarak mı girmedi sayıldı?
  final String? note; // Açıklama veya ders listesi detayı

  AttendanceLogModel({
    required this.dateKey,
    required this.status,
    this.isAutoAssigned = false,
    this.isRetroactivelyCorrected = false,
    required this.updatedAt,
    this.lessonsCount = 1,
    this.isFullDay = false,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'status': status.name,
      'isAutoAssigned': isAutoAssigned,
      'isRetroactivelyCorrected': isRetroactivelyCorrected,
      'updatedAt': updatedAt.toIso8601String(),
      'lessonsCount': lessonsCount,
      'isFullDay': isFullDay,
      'note': note,
    };
  }

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLogModel(
      dateKey: json['dateKey'] as String,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.attended,
      ),
      isAutoAssigned: json['isAutoAssigned'] as bool? ?? false,
      isRetroactivelyCorrected: json['isRetroactivelyCorrected'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      lessonsCount: json['lessonsCount'] as int? ?? 1,
      isFullDay: json['isFullDay'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  AttendanceLogModel copyWith({
    String? dateKey,
    AttendanceStatus? status,
    bool? isAutoAssigned,
    bool? isRetroactivelyCorrected,
    DateTime? updatedAt,
    int? lessonsCount,
    bool? isFullDay,
    String? note,
  }) {
    return AttendanceLogModel(
      dateKey: dateKey ?? this.dateKey,
      status: status ?? this.status,
      isAutoAssigned: isAutoAssigned ?? this.isAutoAssigned,
      isRetroactivelyCorrected: isRetroactivelyCorrected ?? this.isRetroactivelyCorrected,
      updatedAt: updatedAt ?? this.updatedAt,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      isFullDay: isFullDay ?? this.isFullDay,
      note: note ?? this.note,
    );
  }
}
