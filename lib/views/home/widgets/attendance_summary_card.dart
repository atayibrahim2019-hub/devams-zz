import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../history/history_archive_screen.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final CourseModel course;

  const AttendanceSummaryCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor = AppColors.success;
    String statusText = 'Durum İyi';
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (course.isFailedByAbsence) {
      statusColor = AppColors.danger;
      statusText = 'Devamsızlık Sınırı Aşıldı!';
      statusIcon = Icons.cancel_outlined;
    } else if (course.isCriticalAttendance) {
      statusColor = AppColors.warning;
      statusText = 'Kritik Eşik (${course.remainingAbsenceAllowed} Hak)';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ders Başlığı ve Durum Rozeti
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (course.code.isNotEmpty) ...[
                      Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      course.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrik Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Devamsızlık',
                  value: '${course.absentCount}',
                  sublabel: 'Ders Saati',
                  color: AppColors.danger,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Kalan Hak',
                  value: '${course.remainingAbsenceAllowed}',
                  sublabel: 'İzin: ${course.maxAllowedAbsence}',
                  color: AppColors.accent,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Katılım',
                  value: '%${course.attendancePercentage.toStringAsFixed(0)}',
                  sublabel: '${course.attendedCount} Girilen',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // İlerleme Çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: course.maxAllowedAbsence > 0
                  ? (course.absentCount / course.maxAllowedAbsence).clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                course.isFailedByAbsence
                    ? AppColors.danger
                    : (course.isCriticalAttendance ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Alt Detay ve Geçmişe Gitme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maksimum Devamsızlık Sınırı: ${course.maxAllowedAbsence} Ders',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${course.totalSessionsCount} Toplam',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sublabel,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
