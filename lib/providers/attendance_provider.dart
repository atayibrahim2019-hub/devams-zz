import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/course_model.dart';
import '../data/models/attendance_log_model.dart';
import '../data/models/exam_model.dart';
import '../data/models/archived_term_model.dart';
import '../data/models/schedule_item_model.dart';
import '../data/services/storage_service.dart';
import '../core/utils/date_time_utils.dart';

class AttendanceProvider with ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<CourseModel> _courses = [];
  String _selectedCourseId = '';
  List<ArchivedTermModel> _archivedTerms = [];

  AttendanceProvider(this._storageService) {
    _init();
  }

  List<CourseModel> get courses => _courses;
  List<ArchivedTermModel> get archivedTerms => _archivedTerms;

  CourseModel? get selectedCourse {
    if (_courses.isEmpty) return null;
    return _courses.firstWhere(
      (c) => c.id == _selectedCourseId,
      orElse: () => _courses.first,
    );
  }

  void _init() {
    _courses = _storageService.getCourses();
    _archivedTerms = _storageService.getArchivedTerms();

    if (_courses.isEmpty) {
      // Varsayılan boş ders kaydı — kullanıcı Ayarlar'dan kendi dersini girer
      final defaultCourse = CourseModel(
        id: _uuid.v4(),
        name: 'Dersim',
        code: '',
        instructor: '',
        maxAllowedAbsence: 4,
        classDays: [1],
        classStartTime: '09:00',
        classEndTime: '12:00',
        smartWindowDeadlineHour: 18,
        weeklySchedule: [],
      );
      _courses.add(defaultCourse);
      _selectedCourseId = defaultCourse.id;
      _storageService.saveCourses(_courses);
    } else {
      _selectedCourseId = _courses.first.id;
    }

    // Açılışta akıllı kontrolü tetikle
    evaluateDailyAttendance();
  }

  /// Aktif dersi değiştirme
  void selectCourse(String id) {
    _selectedCourseId = id;
    evaluateDailyAttendance();
    notifyListeners();
  }

  /// Günlük otomatik kontrol mekanizması
  void evaluateDailyAttendance() {
    final course = selectedCourse;
    if (course == null) return;

    final todayKey = DateTimeUtils.getTodayKey();
    final now = DateTime.now();
    final todayWeekday = now.weekday;

    // Bugün ders programında veya ders günlerinde var mı?
    final scheduledToday = course.getScheduleForWeekday(todayWeekday);
    final isClassDay = scheduledToday.isNotEmpty || course.classDays.contains(todayWeekday);

    if (isClassDay) {
      final existingLog = course.attendanceLogs[todayKey];
      final endTimeParts = course.classEndTime.split(':');
      final endHour = int.tryParse(endTimeParts.isNotEmpty ? endTimeParts[0] : '18') ?? 18;
      final endMinute = int.tryParse(endTimeParts.length > 1 ? endTimeParts[1] : '0') ?? 0;
      final classEndTime = DateTime(now.year, now.month, now.day, endHour, endMinute);

      if (existingLog == null && now.isAfter(classEndTime)) {
        // Otomatik 'Girildi' olarak kaydet
        final lessonsCount = course.getLessonCountForWeekday(todayWeekday);
        final autoLog = AttendanceLogModel(
          dateKey: todayKey,
          status: AttendanceStatus.attended,
          isAutoAssigned: true,
          isRetroactivelyCorrected: false,
          updatedAt: DateTime.now(),
          lessonsCount: lessonsCount,
          isFullDay: true,
          note: '$lessonsCount Ders (Otomatik Girildi)',
        );

        final updatedLogs = Map<String, AttendanceLogModel>.from(course.attendanceLogs);
        updatedLogs[todayKey] = autoLog;

        _updateSelectedCourse(course.copyWith(attendanceLogs: updatedLogs));
      }
    }
  }

  /// GÜN OLARAK GİRMEDİM:
  /// O gün ders programında kaç ders varsa ders programından bu bilgiyi alır
  /// ve o kadar dersi girmedi / devamsızlık sayar.
  Future<int> recordFullDayAbsent({DateTime? targetDate}) async {
    final course = selectedCourse;
    if (course == null) return 0;

    final date = targetDate ?? DateTime.now();
    final dateKey = DateTimeUtils.toDateKey(date);
    final weekday = date.weekday;

    // Ders programından o gün kaç ders olduğunu al
    final dayLessons = course.getScheduleForWeekday(weekday);
    int count = 0;
    if (dayLessons.isNotEmpty) {
      count = dayLessons.fold<int>(0, (sum, item) => sum + item.lessonCount);
    } else {
      count = 1; // Ders programında özel kayıt yoksa en az 1 ders
    }

    final existingLog = course.attendanceLogs[dateKey];
    bool isCorrection = existingLog != null && existingLog.status == AttendanceStatus.attended;

    String lessonNames = dayLessons.isNotEmpty
        ? dayLessons.map((l) => '${l.courseName} (${l.startTime}-${l.endTime})').join(', ')
        : course.name;

    final newLog = AttendanceLogModel(
      dateKey: dateKey,
      status: AttendanceStatus.absent,
      isAutoAssigned: false,
      isRetroactivelyCorrected: isCorrection,
      updatedAt: DateTime.now(),
      lessonsCount: count,
      isFullDay: true,
      note: '$count Ders Devamsızlık • $lessonNames',
    );

    final updatedLogs = Map<String, AttendanceLogModel>.from(course.attendanceLogs);
    updatedLogs[dateKey] = newLog;

    await _updateSelectedCourse(course.copyWith(attendanceLogs: updatedLogs));
    return count;
  }

  /// Günü "Derse Girdim" Olarak Düzeltme (Devamsızlığı Kaldırır)
  Future<void> recordFullDayAttended({DateTime? targetDate}) async {
    final course = selectedCourse;
    if (course == null) return;

    final date = targetDate ?? DateTime.now();
    final dateKey = DateTimeUtils.toDateKey(date);
    final weekday = date.weekday;

    final dayLessons = course.getScheduleForWeekday(weekday);
    int count = dayLessons.isNotEmpty
        ? dayLessons.fold<int>(0, (sum, item) => sum + item.lessonCount)
        : 1;

    final existingLog = course.attendanceLogs[dateKey];
    bool isCorrection = existingLog != null && existingLog.status == AttendanceStatus.absent;

    final newLog = AttendanceLogModel(
      dateKey: dateKey,
      status: AttendanceStatus.attended,
      isAutoAssigned: false,
      isRetroactivelyCorrected: isCorrection,
      updatedAt: DateTime.now(),
      lessonsCount: count,
      isFullDay: true,
      note: '$count Ders Girildi',
    );

    final updatedLogs = Map<String, AttendanceLogModel>.from(course.attendanceLogs);
    updatedLogs[dateKey] = newLog;

    await _updateSelectedCourse(course.copyWith(attendanceLogs: updatedLogs));
  }

  /// Geriye dönük uyumluluk: Bugün için Gün Olarak Girmedim
  Future<int> recordAbsentToday() async {
    return await recordFullDayAbsent(targetDate: DateTime.now());
  }

  /// Geriye dönük uyumluluk: Bugün için Girdim olarak düzelt
  Future<void> recordAttendedToday() async {
    await recordFullDayAttended(targetDate: DateTime.now());
  }

  /// Tekil bir derse özel devamsızlık durumu değiştirme
  Future<void> toggleSingleLessonAbsent(DateTime date, ScheduleItemModel lesson) async {
    final course = selectedCourse;
    if (course == null) return;

    final dateKey = DateTimeUtils.toDateKey(date);
    final existingLog = course.attendanceLogs[dateKey];

    if (existingLog == null || existingLog.status == AttendanceStatus.attended) {
      // Girmedi yap
      await recordFullDayAbsent(targetDate: date);
    } else {
      // Girdi yap
      await recordFullDayAttended(targetDate: date);
    }
  }

  /// Belirli bir günün devamsızlık logunu sorgulama
  AttendanceLogModel? getLogForDate(DateTime date) {
    final course = selectedCourse;
    if (course == null) return null;
    return course.attendanceLogs[DateTimeUtils.toDateKey(date)];
  }

  /// Bugünün devamsızlık logunu sorgulama
  AttendanceLogModel? getTodayLog() {
    return getLogForDate(DateTime.now());
  }

  /// Hangi gün kaç devamsızlık yapıldığının geçmiş listesi (Tarihçe)
  List<AttendanceLogModel> getAbsentLogsHistory() {
    final course = selectedCourse;
    if (course == null) return [];

    final list = course.attendanceLogs.values
        .where((log) => log.status == AttendanceStatus.absent)
        .toList();

    // Tarihe göre en yeniden en eskiye sırala
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  /// Belirli bir tarihteki devamsızlık kaydını tamamen silme / nötrleme
  Future<void> removeLogForDate(String dateKey) async {
    final course = selectedCourse;
    if (course == null) return;

    final updatedLogs = Map<String, AttendanceLogModel>.from(course.attendanceLogs);
    updatedLogs.remove(dateKey);

    await _updateSelectedCourse(course.copyWith(attendanceLogs: updatedLogs));
  }

  /// Manuel Sayaç Ayarı (+ / -)
  Future<void> adjustAttendedCount(int delta) async {
    final course = selectedCourse;
    if (course == null) return;
    int newOffset = course.manualAttendedOffset + delta;
    if (course.attendedCount + delta < 0) return;

    await _updateSelectedCourse(course.copyWith(manualAttendedOffset: newOffset));
  }

  Future<void> adjustAbsentCount(int delta) async {
    final course = selectedCourse;
    if (course == null) return;
    int newOffset = course.manualAbsentOffset + delta;
    if (course.absentCount + delta < 0) return;

    await _updateSelectedCourse(course.copyWith(manualAbsentOffset: newOffset));
  }

  /// Bugün akıllı pencere içinde mi? (18:00'e kadar)
  bool isTodayWithinSmartWindow() {
    final course = selectedCourse;
    int deadlineHour = course?.smartWindowDeadlineHour ?? 18;
    return DateTimeUtils.isWithinSmartWindow(deadlineHour: deadlineHour);
  }

  // --- DERS PROGRAMI YÖNETİMİ ---
  Future<void> addScheduleItem(ScheduleItemModel item) async {
    final course = selectedCourse;
    if (course == null) return;

    final list = List<ScheduleItemModel>.from(course.weeklySchedule)..add(item);
    // Ders günlerini de güncelle
    final days = list.map((s) => s.weekday).toSet().toList()..sort();

    await _updateSelectedCourse(course.copyWith(
      weeklySchedule: list,
      classDays: days,
    ));
  }

  Future<void> updateScheduleItem(ScheduleItemModel item) async {
    final course = selectedCourse;
    if (course == null) return;

    final list = List<ScheduleItemModel>.from(course.weeklySchedule);
    final idx = list.indexWhere((s) => s.id == item.id);
    if (idx != -1) {
      list[idx] = item;
      final days = list.map((s) => s.weekday).toSet().toList()..sort();
      await _updateSelectedCourse(course.copyWith(
        weeklySchedule: list,
        classDays: days,
      ));
    }
  }

  Future<void> deleteScheduleItem(String id) async {
    final course = selectedCourse;
    if (course == null) return;

    final list = course.weeklySchedule.where((s) => s.id != id).toList();
    final days = list.map((s) => s.weekday).toSet().toList()..sort();
    await _updateSelectedCourse(course.copyWith(
      weeklySchedule: list,
      classDays: days,
    ));
  }

  // --- Sınav ve Not Yönetimi ---
  Future<void> addExam(ExamModel exam) async {
    final course = selectedCourse;
    if (course == null) return;

    final updatedExams = List<ExamModel>.from(course.exams)..add(exam);
    await _updateSelectedCourse(course.copyWith(exams: updatedExams));
  }

  Future<void> updateExam(ExamModel exam) async {
    final course = selectedCourse;
    if (course == null) return;

    final index = course.exams.indexWhere((e) => e.id == exam.id);
    if (index != -1) {
      final updatedExams = List<ExamModel>.from(course.exams);
      updatedExams[index] = exam;
      await _updateSelectedCourse(course.copyWith(exams: updatedExams));
    }
  }

  Future<void> deleteExam(String examId) async {
    final course = selectedCourse;
    if (course == null) return;

    final updatedExams = course.exams.where((e) => e.id != examId).toList();
    await _updateSelectedCourse(course.copyWith(exams: updatedExams));
  }

  // --- Sıfırlama ve Arşivleme ---
  Future<void> archiveAndResetTerm({String? customTermTitle}) async {
    final course = selectedCourse;
    if (course == null) return;

    final now = DateTime.now();
    final title = customTermTitle?.trim().isNotEmpty == true
        ? customTermTitle!.trim()
        : '${now.year} - ${now.year + 1} Dönemi (${course.name})';

    final archiveRecord = ArchivedTermModel(
      id: _uuid.v4(),
      termTitle: title,
      archivedAt: now,
      courseName: course.name,
      courseCode: course.code,
      totalSessions: course.totalSessionsCount,
      attendedSessions: course.attendedCount,
      absentSessions: course.absentCount,
      attendanceRate: course.attendancePercentage,
      exams: List<ExamModel>.from(course.exams),
      calculatedAverage: course.calculatedAverage,
    );

    _archivedTerms.insert(0, archiveRecord);
    await _storageService.saveArchivedTerms(_archivedTerms);

    final resetCourse = course.copyWith(
      attendanceLogs: {},
      manualAttendedOffset: 0,
      manualAbsentOffset: 0,
      exams: [],
    );

    await _updateSelectedCourse(resetCourse);
  }

  Future<void> deleteArchivedTerm(String id) async {
    _archivedTerms.removeWhere((t) => t.id == id);
    await _storageService.saveArchivedTerms(_archivedTerms);
    notifyListeners();
  }

  // --- Ders Detaylarını Güncelleme ---
  Future<void> updateCourseDetails({
    required String name,
    required String code,
    required String instructor,
    required int maxAllowedAbsence,
    required List<int> classDays,
    required String startTime,
    required String endTime,
    required int smartDeadlineHour,
  }) async {
    final course = selectedCourse;
    if (course == null) return;

    final updated = course.copyWith(
      name: name,
      code: code,
      instructor: instructor,
      maxAllowedAbsence: maxAllowedAbsence,
      classDays: classDays,
      classStartTime: startTime,
      classEndTime: endTime,
      smartWindowDeadlineHour: smartDeadlineHour,
    );

    await _updateSelectedCourse(updated);
  }

  Future<void> _updateSelectedCourse(CourseModel updated) async {
    final index = _courses.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _courses[index] = updated;
    } else {
      _courses.add(updated);
    }
    await _storageService.saveCourses(_courses);
    notifyListeners();
  }
}
