import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../providers/app_provider.dart';
import '../../providers/attendance_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final course = attendanceProvider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar & Kişiselleştirme'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. Profil / İsim Ayarı
          _buildSectionHeader('PROFİL & KULLANICI', isDark),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  radius: 24,
                  child: Text(
                    appProvider.userName.isNotEmpty
                        ? appProvider.userName[0].toUpperCase()
                        : 'Ö',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appProvider.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'KOU Öğrenci Profili',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showEditNameDialog(context, appProvider.userName),
                  child: const Text('Düzenle'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Tema Yönetimi (System / Light / Dark)
          _buildSectionHeader('TEMA & GÖRÜNÜM', isDark),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                _buildThemeRadioTile(
                  context: context,
                  title: 'Sistem Teması (Otomatik)',
                  subtitle: 'Cihazınızın geçerli temasını takip eder',
                  value: ThemeMode.system,
                  groupValue: appProvider.themeMode,
                  icon: Icons.brightness_auto_rounded,
                  onChanged: (mode) => appProvider.updateThemeMode(mode!),
                ),
                const Divider(height: 16),
                _buildThemeRadioTile(
                  context: context,
                  title: 'Aydınlık Mod (Light)',
                  subtitle: 'Ferah ve net görünüm',
                  value: ThemeMode.light,
                  groupValue: appProvider.themeMode,
                  icon: Icons.light_mode_rounded,
                  onChanged: (mode) => appProvider.updateThemeMode(mode!),
                ),
                const Divider(height: 16),
                _buildThemeRadioTile(
                  context: context,
                  title: 'Karanlık Mod (OLED Dark)',
                  subtitle: 'Gece dostu derin siyahlar, pil tasarrufu',
                  value: ThemeMode.dark,
                  groupValue: appProvider.themeMode,
                  icon: Icons.dark_mode_rounded,
                  onChanged: (mode) => appProvider.updateThemeMode(mode!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Ders Bilgileri ve Akıllı Sayaç Yapılandırması
          if (course != null) ...[
            _buildSectionHeader('DERS VE AKILLI SAYAC YAPILANDIRMASI', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ListTile(
                title: Text(
                  course.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Maks. Devamsızlık: ${course.maxAllowedAbsence} ders • Akıllı Pencere: ${course.smartWindowDeadlineHour}:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _showEditCourseDialog(context, course),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Dönemi Bitir / Canlı Verileri Sıfırla ve Arşivle
          _buildSectionHeader('DÖNEM YÖNETİMİ & SIFIRLAMA', isDark),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.archive_outlined, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dönemi Bitir ve Arşivle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Canlı sayaçlar arşive aktarılır ve sıfırdan başlar.',
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetConfirmDialog(context),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Mevcut Dönemi Arşivle ve Sıfırla'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // App Info & Version
          Center(
            child: Column(
              children: [
                Text(
                  'DevamsızlıkKOU • v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kocaeli Üniversitesi Öğrencileri İçin Geliştirildi',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary.withOpacity(0.6) : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İsmini Güncelle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Adın'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AppProvider>().updateUserName(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, course) {
    final nameCtrl = TextEditingController(text: course.name);
    final codeCtrl = TextEditingController(text: course.code);
    final instructorCtrl = TextEditingController(text: course.instructor);
    final maxAbsenceCtrl = TextEditingController(text: course.maxAllowedAbsence.toString());
    final deadlineCtrl = TextEditingController(text: course.smartWindowDeadlineHour.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ders & Takip Ayarları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ders Adı'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Ders Kodu (örn: BLM301)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: instructorCtrl,
                decoration: const InputDecoration(labelText: 'Öğretim Görevlisi'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: maxAbsenceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Maks. İzin Verilen Devamsızlık'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deadlineCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Akıllı Pencere Bitiş Saati (örn: 18)',
                  suffixText: ':00',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceProvider>().updateCourseDetails(
                    name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : course.name,
                    code: codeCtrl.text.trim(),
                    instructor: instructorCtrl.text.trim(),
                    maxAllowedAbsence: int.tryParse(maxAbsenceCtrl.text) ?? course.maxAllowedAbsence,
                    classDays: course.classDays,
                    startTime: course.classStartTime,
                    endTime: course.classEndTime,
                    smartDeadlineHour: int.tryParse(deadlineCtrl.text) ?? 18,
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    final titleCtrl = TextEditingController(
      text: '${DateTime.now().year} - ${DateTime.now().year + 1} Dönemi',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dönemi Sıfırla ve Arşivle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu işlem mevcut devamsızlık sayaçlarını ve sınav notlarını geçmiş arşive kaydedecek ve yeni dönem için sayaçları sıfırlayacaktır.\n\nİsminiz ve tema tercihleriniz korunur.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Arşiv Dönem Başlığı',
                hintText: 'örn: 2024-2025 Güz Dönemi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceProvider>().archiveAndResetTerm(
                    customTermTitle: titleCtrl.text,
                  );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dönem başarıyla arşivlendi ve sayaçlar sıfırlandı.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Arşivle ve Sıfırla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

