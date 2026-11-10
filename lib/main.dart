import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/app_provider.dart';
import 'providers/attendance_provider.dart';
import 'views/main_nav_scaffold.dart';
import 'views/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem durum çubuğu ve navigasyon çubuğu stili
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1128),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Türkçe tarih formatlama kütüphanesini başlat
  try {
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('tr', null);
  } catch (e) {
    debugPrint('DateFormatting initialize error: $e');
  }

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(storageService)),
      ],
      child: const DevamsizlikKOUApp(),
    ),
  );
}

class DevamsizlikKOUApp extends StatelessWidget {
  const DevamsizlikKOUApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'DevamsızlıkKOU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appProvider.themeMode,
      home: appProvider.isOnboardingDone
          ? const MainNavScaffold()
          : const OnboardingScreen(),
    );
  }
}
