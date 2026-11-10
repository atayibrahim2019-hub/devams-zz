import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/attendance_log_model.dart';
import '../../../data/models/course_model.dart';
import '../../../providers/attendance_provider.dart';

class QuickActionSection extends StatelessWidget {
  final CourseModel course;

  const QuickActionSection({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final todayLog = provider.getTodayLog();
    final isWithinWindow = provider.isTodayWithinSmartWindow();
    final isTodayAbsent = todayLog?.status == AttendanceStatus.absent;
    final isTodayAttended = todayLog?.status == AttendanceStatus.attended;

    final now = DateTime.now();
    final todayLessonsCount = course.getLessonCountForWeekday(now.weekday);
    final effectiveLessons = todayLessonsCount > 0 ? todayLessonsCount : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTodayAbsent
              ? AppColors.danger.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isTodayAbsent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Akıllı Saat Rozeti
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günün Ders Durumu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isWithinWindow
                      ? AppColors.primaryLight.withOpacity(0.12)
                      : (isDark ? AppColors.darkSurface : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWithinWindow
                        ? AppColors.primaryLight.withOpacity(0.3)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isWithinWindow
                          ? AppColors.primaryLight
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isWithinWindow
                          ? '${course.smartWindowDeadlineHour}:00\'a Kadar Düzeltilebilir'
                          : 'Pencere Kapandı (${course.smartWindowDeadlineHour}:00)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isWithinWindow
                            ? (isDark ? AppColors.primaryLight : AppColors.primary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Durum Banner'ı ve Aksiyon
          if (isTodayAbsent) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Column(
                children: [
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
                              'Bugün Gün Olarak Girmedin',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ders programındaki $effectiveLessons ders devamsızlık hanene işlendi.',
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
                  // Düzeltme Butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.recordFullDayAttended();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Durum düzeltildi: Gün "Girildi" olarak güncellendi.'),
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
                ],
              ),
            ),
          ] else ...[
            Column(
              children: [
                if (isTodayAttended && todayLog?.isAutoAssigned == true) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sistem bugünkü dersleri otomatik "Girildi" saydı.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // "GÜN OLARAK GİRMEDİM" Ana Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final count = await provider.recordFullDayAbsent();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Bugün girmedi sayıldı: Ders programındaki $count ders devamsızlık hanenize işlendi.',
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

                const SizedBox(height: 10),
                Text(
                  'Ders programındaki ders sayısı ($effectiveLessons ders) baz alınarak devamsızlık sayılır.\nAkşam saat ${course.smartWindowDeadlineHour}:00\'a kadar istediğin an düzeltebilirsin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 28),

          // Manuel Sayaç Ayarları (+ / -)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manuel Sayaç Ayarı:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Row(
                children: [
                  _buildQuickCounterChip(
                    context,
                    label: '+1 Girilen',
                    color: AppColors.success,
                    onTap: () => provider.adjustAttendedCount(1),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickCounterChip(
                    context,
                    label: '+1 Devamsız',
                    color: AppColors.danger,
                    onTap: () => provider.adjustAbsentCount(1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCounterChip(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
