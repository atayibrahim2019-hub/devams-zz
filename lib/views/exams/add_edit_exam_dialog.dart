import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../../providers/attendance_provider.dart';

class AddEditExamDialog extends StatefulWidget {
  final ExamModel? exam;

  const AddEditExamDialog({Key? key, this.exam}) : super(key: key);

  @override
  State<AddEditExamDialog> createState() => _AddEditExamDialogState();
}

class _AddEditExamDialogState extends State<AddEditExamDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _scoreController;
  late TextEditingController _weightController;
  String? _selectedLetterGrade;
  bool _useLetterGrade = false;

  final List<String> _letterGrades = [
    'AA', 'BA', 'BB', 'CB', 'CC', 'DC', 'DD', 'FD', 'FF'
  ];

  @override
  void initState() {
    super.initState();
    final exam = widget.exam;
    _titleController = TextEditingController(text: exam?.title ?? '');
    _scoreController = TextEditingController(text: exam?.score?.toStringAsFixed(0) ?? '');
    _weightController = TextEditingController(text: exam != null && exam.weight > 0 ? exam.weight.toStringAsFixed(0) : '40');
    _selectedLetterGrade = exam?.letterGrade;
    _useLetterGrade = exam?.letterGrade != null && (exam?.score == null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AttendanceProvider>();
    final title = _titleController.text.trim();
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final score = _useLetterGrade ? null : double.tryParse(_scoreController.text);
    final letter = _useLetterGrade ? _selectedLetterGrade : null;

    if (widget.exam == null) {
      final newExam = ExamModel(
        id: const Uuid().v4(),
        title: title,
        score: score,
        letterGrade: letter,
        weight: weight,
        date: DateTime.now(),
      );
      provider.addExam(newExam);
    } else {
      final updated = widget.exam!.copyWith(
        title: title,
        score: score,
        letterGrade: letter,
        weight: weight,
      );
      provider.updateExam(updated);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.exam != null;

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Sınavı Düzenle' : 'Yeni Sınav Notu Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Sınav Adı
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Sınav Adı (örn: Vize 1, Final, Quiz 2)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Sınav adı zorunludur' : null,
              ),
              const SizedBox(height: 14),

              // Not Türü Seçimi (Puan vs Harf)
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('0-100 Puan'),
                    selected: !_useLetterGrade,
                    onSelected: (val) {
                      setState(() => _useLetterGrade = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Harf Notu'),
                    selected: _useLetterGrade,
                    onSelected: (val) {
                      setState(() {
                        _useLetterGrade = true;
                        _selectedLetterGrade ??= 'AA';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (!_useLetterGrade) ...[
                TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Alınan Not (0 - 100)',
                    prefixIcon: Icon(Icons.score_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Not zorunludur';
                    final n = double.tryParse(val);
                    if (n == null || n < 0 || n > 100) return '0 ile 100 arasında bir değer girin';
                    return null;
                  },
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  value: _selectedLetterGrade,
                  decoration: const InputDecoration(
                    labelText: 'Harf Notu',
                    prefixIcon: Icon(Icons.font_download_outlined),
                  ),
                  items: _letterGrades.map((grade) {
                    return DropdownMenuItem(value: grade, child: Text(grade));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedLetterGrade = val),
                ),
              ],
              const SizedBox(height: 14),

              // Ağırlık Yüzdesi
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dönem Sonu Etki Oranı (% Ağırlık)',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.pie_chart_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final n = double.tryParse(val);
                  if (n == null || n < 0 || n > 100) return '0 - 100 arasında olmalıdır';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (isEditing) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                      tooltip: 'Sınavı Sil',
                      onPressed: () {
                        context.read<AttendanceProvider>().deleteExam(widget.exam!.id);
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isEditing ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

