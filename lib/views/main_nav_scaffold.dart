import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'home/home_screen.dart';
import 'home/today_schedule_view.dart';
import 'schedule/schedule_tab.dart';
import 'exams/exams_tab.dart';
import 'history/history_archive_screen.dart';
import 'settings/settings_screen.dart';

class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({Key? key}) : super(key: key);

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  // Fotoğraftaki gibi "Bugün" (index 1) varsayılan olarak açık başlayabilir veya kullanıcı değiştirebilir
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    HomeScreen(), // 0: Özet
    TodayScheduleView(), // 1: Bugün (Fotoğraftaki ekran)
    ScheduleTab(), // 2: Takvim / Program (Ders Programı Girdisi)
    ExamsTab(), // 3: Sınavlar (Düzeltildi)
    HistoryArchiveScreen(), // 4: Geçmiş & Devamsızlık Kayıtları (Düzeltildi)
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            setState(() => _currentIndex = idx);
          },
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightSurface,
          indicatorColor: AppColors.primary,
          elevation: 0,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.white),
              label: 'Özet',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today_rounded, color: Colors.white),
              label: 'Bugün',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.white),
              label: 'Program',
            ),
            NavigationDestination(
              icon: Icon(Icons.grade_outlined),
              selectedIcon: Icon(Icons.grade_rounded, color: Colors.white),
              label: 'Sınavlar',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded, color: Colors.white),
              label: 'Geçmiş',
            ),
          ],
        ),
      ),
    );
  }
}
