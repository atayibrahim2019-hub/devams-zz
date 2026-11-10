import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/schedule_item_model.dart';
import '../../providers/attendance_provider.dart';
import 'add_edit_schedule_dialog.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({Key? key}) : super(key: key);

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  int _selectedWeekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final course = provider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Haftalık Ders Programı')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    final daySchedule = course.getScheduleForWeekday(_selectedWeekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Ders Programı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Ders Ekle',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEditScheduleDialog(initialWeekday: _selectedWeekday),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Gün Seçici Şerit (Pazartesi ... Pazar)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(7, (index) {
                  final dayIndex = index + 1;
                  final isSelected = _selectedWeekday == dayIndex;
                  final dayName = DateTimeUtils.getWeekdayName(dayIndex);
                  final count = course.getScheduleForWeekday(dayIndex).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedWeekday = dayIndex),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkCard : AppColors.lightBg),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateTimeUtils.getShortWeekdayName(dayIndex),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              count > 0 ? '$count ders' : '-',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.85)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Seçili Günün Ders Listesi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Günlük Özet Başlığı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateTimeUtils.getWeekdayName(_selectedWeekday)} Günü',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '${daySchedule.length} Ders Kayıtlı',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (daySchedule.isEmpty) ...[
                  _buildEmptyDayState(context, isDark),
                ] else ...[
                  ...daySchedule.map((item) => _buildScheduleCard(context, provider, item, isDark)),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddEditScheduleDialog(initialWeekday: _selectedWeekday),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Bu Güne Ders Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyDayState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 42,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Bu Gün İçin Ders Yok',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${DateTimeUtils.getWeekdayName(_selectedWeekday)} gününe ait ders saatlerini ve yerini ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    AttendanceProvider provider,
    ScheduleItemModel item,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saat Bloğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  item.startTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryLight,
                  ),
                ),
                Container(
                  width: 14,
                  height: 1,
                  color: AppColors.primaryLight.withOpacity(0.4),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  item.endTime,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Ders Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.location.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPillBg : AppColors.lightPillBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place_rounded, size: 12, color: AppColors.primaryLight),
                            const SizedBox(width: 3),
                            Text(
                              item.location,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${item.lessonCount} Ders Saati',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Düzenle & Sil Menüsü
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            onSelected: (val) {
              if (val == 'edit') {
                showDialog(
                  context: context,
                  builder: (_) => AddEditScheduleDialog(item: item),
                );
              } else if (val == 'delete') {
                provider.deleteScheduleItem(item.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

