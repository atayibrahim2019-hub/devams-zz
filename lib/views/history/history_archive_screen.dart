import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/attendance_log_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/archived_term_model.dart';
import '../../providers/attendance_provider.dart';

class HistoryArchiveScreen extends StatefulWidget {
  const HistoryArchiveScreen({Key? key}) : super(key: key);

  @override
  State<HistoryArchiveScreen> createState() => _HistoryArchiveScreenState();
}

class _HistoryArchiveScreenState extends State<HistoryArchiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final course = provider.selectedCourse;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final absentLogs = provider.getAbsentLogsHistory();
    final archivedTerms = provider.archivedTerms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş ve Devamsızlık Kayıtları'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: [
            Tab(
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              text: 'Devamsızlık Günlüğü (${absentLogs.length})',
            ),
            Tab(
              icon: const Icon(Icons.archive_outlined, size: 18),
              text: 'Dönem Arşivleri (${archivedTerms.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Tab: Devamsızlık Günlüğü (Hangi gün kaç devamsızlık yapıldı)
          _buildDailyAbsenceLogList(context, provider, course, absentLogs, isDark),

          // 2. Tab: Dönem Arşivleri
          _buildArchivedTermsList(context, provider, archivedTerms, isDark),
        ],
      ),
    );
  }

  /// 1. Sekme: Günlük Devamsızlık Geçmişi
  Widget _buildDailyAbsenceLogList(
    BuildContext context,
    AttendanceProvider provider,
    CourseModel? course,
    List<AttendanceLogModel> absentLogs,
    bool isDark,
  ) {
    if (absentLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Harika! Devamsızlığın Bulunmuyor',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Herhangi bir gün "Gün Olarak Girmedim" dediğinde o günkü devamsızlıkların ders sayısıyla birlikte burada listelenecektir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    int totalAbsentLessons = 0;
    for (var l in absentLogs) {
      totalAbsentLessons += l.lessonsCount;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // İstatistik Özet Kartı
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1B2A5E), const Color(0xFF141F48)]
                  : [const Color(0xFFEFF3FE), const Color(0xFFF7F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(
                'Devamsız Gün',
                '${absentLogs.length}',
                AppColors.warning,
                isDark,
              ),
              Container(
                width: 1,
                height: 38,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              _buildStatMetric(
                'Toplam Ders',
                '$totalAbsentLessons',
                AppColors.danger,
                isDark,
              ),
              Container(
                width: 1,
                height: 38,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              _buildStatMetric(
                'Kalan Hak',
                course != null ? '${course.remainingAbsenceAllowed}' : '-',
                AppColors.accent,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'Devamsızlık Yapılan Günler:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),

        ...absentLogs.map((log) {
          DateTime? logDate;
          try {
            logDate = DateTime.parse(log.dateKey);
          } catch (_) {
            logDate = log.updatedAt;
          }

          final dateStr = DateTimeUtils.formatFullDisplay(logDate);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İkon Rozeti
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cancel_outlined,
                      color: AppColors.danger,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${log.lessonsCount} Ders Devamsızlık Sayıldı',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                      if (log.note != null && log.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          log.note!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Düzeltme (Geri al) butonu
                IconButton(
                  icon: const Icon(Icons.undo_rounded, size: 20),
                  color: AppColors.primaryLight,
                  tooltip: 'Girdim Olarak Düzelt',
                  onPressed: () {
                    _confirmRevertAttendance(context, provider, logDate!, log.dateKey, log.lessonsCount);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 2. Sekme: Arşivlenmiş Dönemler Listesi
  Widget _buildArchivedTermsList(
    BuildContext context,
    AttendanceProvider provider,
    List<ArchivedTermModel> archivedTerms,
    bool isDark,
  ) {
    if (archivedTerms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 38,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Henüz Arşivlenmiş Dönem Yok',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dönem sonunda Ayarlar ekranından ders verilerini sıfırladığında tüm istatistikler burada arşivlenir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: archivedTerms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final term = archivedTerms[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term.termTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Arşivlenme: ${DateTimeUtils.formatDisplay(term.archivedAt)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                    tooltip: 'Arşivden Sil',
                    onPressed: () => _confirmDeleteArchive(context, provider, term.id),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatMetric('Toplam', '${term.totalSessions}', isDark ? Colors.white : Colors.black, isDark),
                    ),
                    Expanded(
                      child: _buildStatMetric('Girilen', '${term.attendedSessions}', AppColors.success, isDark),
                    ),
                    Expanded(
                      child: _buildStatMetric('Devamsız', '${term.absentSessions}', AppColors.danger, isDark),
                    ),
                    Expanded(
                      child: _buildStatMetric('Katılım', '%${term.attendanceRate.toStringAsFixed(0)}', AppColors.accent, isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatMetric(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _confirmRevertAttendance(
    BuildContext context,
    AttendanceProvider provider,
    DateTime date,
    String dateKey,
    int lessonsCount,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Devamsızlığı Düzelt'),
        content: Text(
          '${DateTimeUtils.formatDisplay(date)} tarihindeki $lessonsCount derslik devamsızlığı kaldırmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.recordFullDayAttended(targetDate: date);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt güncellendi: Derse Girildi olarak değiştirildi.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Girdim Olarak Düzelt'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteArchive(BuildContext context, AttendanceProvider provider, String archiveId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arşiv Kaydını Sil'),
        content: const Text('Bu geçmiş dönem kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteArchivedTerm(archiveId);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
