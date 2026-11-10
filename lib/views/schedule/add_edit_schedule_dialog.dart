import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/schedule_item_model.dart';
import '../../providers/attendance_provider.dart';

class AddEditScheduleDialog extends StatefulWidget {
  final ScheduleItemModel? item;
  final int? initialWeekday;

  const AddEditScheduleDialog({Key? key, this.item, this.initialWeekday}) : super(key: key);

  @override
  State<AddEditScheduleDialog> createState() => _AddEditScheduleDialogState();
}

class _AddEditScheduleDialogState extends State<AddEditScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late TextEditingController _lessonCountController;
  late int _selectedWeekday;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _selectedWeekday = item?.weekday ?? widget.initialWeekday ?? DateTime.now().weekday;
    _courseNameController = TextEditingController(text: item?.courseName ?? '');
    _startTimeController = TextEditingController(text: item?.startTime ?? '09:00');
    _endTimeController = TextEditingController(text: item?.endTime ?? '12:00');
    _locationController = TextEditingController(text: item?.location ?? '');
    _lessonCountController = TextEditingController(text: item?.lessonCount.toString() ?? '1');
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _lessonCountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AttendanceProvider>();
    final courseName = _courseNameController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final location = _locationController.text.trim();
    final lessonCount = int.tryParse(_lessonCountController.text.trim()) ?? 1;

    if (widget.item == null) {
      final newItem = ScheduleItemModel(
        id: const Uuid().v4(),
        weekday: _selectedWeekday,
        courseName: courseName,
        startTime: startTime,
        endTime: endTime,
        location: location.isNotEmpty ? location : '-',
        lessonCount: lessonCount > 0 ? lessonCount : 1,
      );
      provider.addScheduleItem(newItem);
    } else {
      final updated = widget.item!.copyWith(
        weekday: _selectedWeekday,
        courseName: courseName,
        startTime: startTime,
        endTime: endTime,
        location: location.isNotEmpty ? location : '-',
        lessonCount: lessonCount > 0 ? lessonCount : 1,
      );
      provider.updateScheduleItem(updated);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.item != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Dersi Düzenle' : 'Programa Ders Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gün Seçimi
              Text(
                'Ders Günü:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(7, (i) {
                  final dayIndex = i + 1;
                  final isSelected = _selectedWeekday == dayIndex;
                  return ChoiceChip(
                    label: Text(
                      DateTimeUtils.getShortWeekdayName(dayIndex),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedWeekday = dayIndex);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Ders Adı
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Ders Adı',
                  hintText: 'Örn: Matematik, Fizik, İngilizce...',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ders adı gereklidir' : null,
              ),
              const SizedBox(height: 14),

              // Başlangıç & Bitiş Saati
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Başlangıç',
                        hintText: '08:30',
                        prefixIcon: Icon(Icons.access_time_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Saat girin' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Bitiş',
                        hintText: '12:20',
                        prefixIcon: Icon(Icons.update_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Saat girin' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Yer / Derslik ve Ders Saati Sayısı
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Derslik / Yer',
                        hintText: 'Örn: Derslik A101, Lab 2',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _lessonCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ders Saati',
                        hintText: '1',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: (val) {
                        final n = int.tryParse(val ?? '');
                        if (n == null || n <= 0) return 'Geçerli sayı';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isEditing ? 'Değişiklikleri Kaydet' : 'Dersi Programa Ekle',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

