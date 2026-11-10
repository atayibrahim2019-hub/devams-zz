import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../providers/app_provider.dart';
import '../../providers/attendance_provider.dart';
import 'widgets/attendance_summary_card.dart';
import 'widgets/quick_action_section.dart';
import 'widgets/course_schedule_info.dart';
import 'widgets/exam_list_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final course = attendanceProvider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (course == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    final greeting = DateTimeUtils.getGreeting(appProvider.userName.isNotEmpty ? appProvider.userName : 'Öğrenci');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 20,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DevamsızlıkKOU',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar & Profil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          attendanceProvider.evaluateDailyAttendance();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Selamlama Başlığı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appProvider.userName.isNotEmpty ? appProvider.userName : "Öğrenci"}, genel devamsızlık ve ders durumun:',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Ana Özet Sayaç Kartı
            AttendanceSummaryCard(course: course),
            const SizedBox(height: 16),

            // 2. Akıllı "GÜN OLARAK GİRMEDİM" ve Hızlı Aksiyon Kartı
            QuickActionSection(course: course),
            const SizedBox(height: 16),

            // 3. Sınav Notları Özeti
            ExamListCard(course: course),
            const SizedBox(height: 16),

            // 4. Haftalık Ders Programı Özeti
            CourseScheduleInfo(course: course),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
