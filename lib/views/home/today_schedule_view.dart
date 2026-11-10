import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/attendance_log_model.dart';
import '../../data/models/schedule_item_model.dart';
import '../../providers/attendance_provider.dart';
import '../schedule/add_edit_schedule_dialog.dart';
import '../settings/settings_screen.dart';

class TodayScheduleView extends StatefulWidget {
  const TodayScheduleView({Key? key}) : super(key: key);

  @override
  State<TodayScheduleView> createState() => _TodayScheduleViewState();
}

class _TodayScheduleViewState extends State<TodayScheduleView> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  void _jumpToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final course = provider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bugün')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    final weekday = _currentDate.weekday;
    final dayLessons = course.getScheduleForWeekday(weekday);
    final log = provider.getLogForDate(_currentDate);
    final isDayAbsent = log != null && log.status == AttendanceStatus.absent;
    final isDayAttended = log != null && log.status == AttendanceStatus.attended;

    final headerRelativeTitle = DateTimeUtils.formatRelativeHeader(_currentDate);
    final formattedFullDate = DateTimeUtils.formatFullDisplay(_currentDate);

    final totalScheduledLessons = dayLessons.isNotEmpty
        ? dayLessons.fold<int>(0, (sum, i) => sum + i.lessonCount)
        : (course.classDays.contains(weekday) ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          tooltip: 'Önceki Gün',
          onPressed: _previousDay,
        ),
        title: GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _currentDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() => _currentDate = picked);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                headerRelativeTitle,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            tooltip: 'Sonraki Gün',
            onPressed: _nextDay,
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded, size: 20),
            tooltip: 'Bugüne Dön',
            onPressed: _jumpToToday,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. ÜST GRADIENT KART (Fotoğraftaki Birebir Indigo-Violet Gradient Başlık)
          _buildTopBanner(
            formattedFullDate: formattedFullDate,
            headerRelativeTitle: headerRelativeTitle,
            totalLessons: totalScheduledLessons,
            isAbsent: isDayAbsent,
          ),
          const SizedBox(height: 16),

          // 2. "GÜN OLARAK GİRMEDİM" VE DURUM KARTI
          _buildDayAttendanceActionCard(
            context: context,
            provider: provider,
            date: _currentDate,
            dayLessonsCount: totalScheduledLessons,
            isAbsent: isDayAbsent,
            isAttended: isDayAttended,
            log: log,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 3. DERS LİSTESİ BAŞLIĞI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günün Dersleri (${dayLessons.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditScheduleDialog(initialWeekday: weekday),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Programa Ekle', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4. DERS KARTLARI (Fotoğraftaki Birebir Kartlar ve Mercan Kırmızısı Butonlar)
          if (dayLessons.isEmpty) ...[
            _buildNoClassesForDay(context, isDark),
          ] else ...[
            ...dayLessons.map((lesson) => _buildLessonSlotCard(
                  context: context,
                  provider: provider,
                  lesson: lesson,
                  date: _currentDate,
                  isDayAbsent: isDayAbsent,
                  isDark: isDark,
                )),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Fotoğraftaki Birebir Üst Gradient Kart
  Widget _buildTopBanner({
    required String formattedFullDate,
    required String headerRelativeTitle,
    required int totalLessons,
    required bool isAbsent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAbsent
              ? [const Color(0xFFC92A2A), const Color(0xFF862E9C)]
              : AppColors.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isAbsent ? const Color(0xFFC92A2A) : AppColors.primary).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih
          Text(
            formattedFullDate,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Ders sayısı vurgusu (Fotoğraftaki gibi: "Haftaya Çarşamba 2 dersiniz var")
          Text(
            isAbsent
                ? '$headerRelativeTitle için $totalLessons ders devamsızlık kaydedildi'
                : (totalLessons > 0
                    ? '$headerRelativeTitle $totalLessons dersiniz var'
                    : '$headerRelativeTitle dersiniz bulunmuyor'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// "GÜN OLARAK GİRMEDİM" Aksiyon Kartı
  Widget _buildDayAttendanceActionCard({
    required BuildContext context,
    required AttendanceProvider provider,
    required DateTime date,
    required int dayLessonsCount,
    required bool isAbsent,
    required bool isAttended,
    required AttendanceLogModel? log,
    required bool isDark,
  }) {
    final effectiveLessons = dayLessonsCount > 0 ? dayLessonsCount : 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAbsent
              ? AppColors.danger.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isAbsent ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isAbsent) ...[
            // Günü girmedi olarak kaydetmiş
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.danger,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bu Günü "Girmedi" Olarak Kaydettiniz',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ders programından alınan $effectiveLessons ders devamsızlık hanenize işlendi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Geri Alma / Düzeltme Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await provider.recordFullDayAttended(targetDate: date);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kayıt düzeltildi: Gün "Girildi" olarak güncellendi.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: const Text('Yanlış Bastım (Derse Girdim Olarak Düzelt)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ] else ...[
            // Henüz girmedi denmemiş: GÜN OLARAK GİRMEDİM BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final missedCount = await provider.recordFullDayAbsent(targetDate: date);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gün kaydedildi: Ders programındaki $missedCount ders devamsızlık hanenize işlendi.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                label: Text(
                  'GÜN OLARAK GİRMEDİM ($effectiveLessons Ders)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Basıldığında ders programından o günkü ders sayısı ($effectiveLessons ders) alınarak devamsızlık sayılır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Birebir Fotoğraftaki Ders Kartı (08:30 - 12:20, Restoratif Diş Tedavisi 5, 📍 Klinik, Mercan Buton)
  Widget _buildLessonSlotCard({
    required BuildContext context,
    required AttendanceProvider provider,
    required ScheduleItemModel lesson,
    required DateTime date,
    required bool isDayAbsent,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saat (Fotoğraftaki sol üst saat metni)
          Text(
            '${lesson.startTime} - ${lesson.endTime}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9FB2DE) : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Ders Adı (Restoratif Diş Tedavisi 5)
          Text(
            lesson.courseName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Yer / Klinik Rozeti (Fotoğraftaki 📍 Klinik ve sağdaki Klinik pill'i)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 15,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lesson.location,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPillBg : AppColors.lightPillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lesson.location,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fotoğraftaki Mercan Kırmızısı Buton: "✕ Gitmedim" (veya "✕ Girmedi")
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await provider.toggleSingleLessonAbsent(date, lesson);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDayAbsent
                    ? const Color(0xFF374151)
                    : AppColors.coralRed, // Canlı mercan kırmızı buton
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDayAbsent ? Icons.check_rounded : Icons.close_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDayAbsent ? 'Girildi Olarak Değiştir' : '✕ Gitmedim',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoClassesForDay(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.weekend_rounded,
            size: 40,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'Bu Gün İçin Ders Tanımlanmamış',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Haftalık ders programından bu güne ders ekleyebilirsiniz.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
