import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/course_model.dart';
import '../../data/models/exam_model.dart';
import '../../providers/attendance_provider.dart';
import 'add_edit_exam_dialog.dart';

class ExamsTab extends StatelessWidget {
  const ExamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final course = provider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sınav ve Not Takibi'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      );
    }

    final avg = course.calculatedAverage;
    final exams = course.exams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav ve Not Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Sınav Ekle',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditExamDialog(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildHeaderCard(course, exams, avg, isDark),
          const SizedBox(height: 20),
          if (exams.isEmpty)
            _buildEmptyState(context, isDark)
          else
            ...exams.map((exam) => _buildExamItem(context, exam, isDark)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    CourseModel course,
    List<ExamModel> exams,
    double? avg,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B2A5E), const Color(0xFF141F48)]
              : [const Color(0xFFE8EEFD), const Color(0xFFF1F5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${exams.length} sınav/not kayıtlı',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  avg != null ? avg.toStringAsFixed(1) : '-',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  'Ortalama',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.grade_outlined,
            size: 48,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Henüz Eklenmiş Sınav Yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vize, Final, Quiz veya Proje notlarını ekle.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditExamDialog(),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Yeni Sınav Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildExamItem(BuildContext context, ExamModel exam, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                exam.letterGrade ??
                    (exam.score != null ? exam.score!.toStringAsFixed(0) : '-'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Etki: %${exam.weight.toStringAsFixed(0)} • ${DateTimeUtils.formatDisplay(exam.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEditExamDialog(exam: exam),
              );
            },
          ),
        ],
      ),
    );
  }
}
