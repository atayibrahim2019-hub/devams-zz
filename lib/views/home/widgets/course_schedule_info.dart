import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/models/course_model.dart';

class CourseScheduleInfo extends StatelessWidget {
  final CourseModel course;

  const CourseScheduleInfo({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final daysStr = course.classDays.map((d) => DateTimeUtils.getWeekdayName(d)).join(', ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded, size: 18, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                'Ders Programı & Bilgiler',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            label: 'Ders Günleri',
            value: daysStr.isNotEmpty ? daysStr : 'Belirtilmedi',
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            label: 'Ders Saatleri',
            value: '${course.classStartTime} - ${course.classEndTime}',
            icon: Icons.access_time_rounded,
          ),
          if (course.instructor.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              label: 'Öğretim Görevlisi',
              value: course.instructor,
              icon: Icons.person_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

