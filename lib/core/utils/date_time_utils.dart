import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static const List<String> _turkishMonths = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  static const List<String> _turkishDays = [
    '',
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  static String toDateKey(DateTime dateTime) {
    return _dateKeyFormat.format(dateTime);
  }

  static String getTodayKey() {
    return _dateKeyFormat.format(DateTime.now());
  }

  /// Güvenli Tarih Formatı (örn: "04 Kasım 2026")
  static String formatDisplay(DateTime dateTime) {
    try {
      return DateFormat('d MMMM yyyy', 'tr_TR').format(dateTime);
    } catch (_) {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = (dateTime.month >= 1 && dateTime.month <= 12)
          ? _turkishMonths[dateTime.month]
          : '${dateTime.month}';
      return '$day $month ${dateTime.year}';
    }
  }

  /// Güvenli Tam Tarih Formatı (örn: "04 Kasım 2026, Çarşamba")
  static String formatFullDisplay(DateTime dateTime) {
    try {
      return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(dateTime);
    } catch (_) {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = (dateTime.month >= 1 && dateTime.month <= 12)
          ? _turkishMonths[dateTime.month]
          : '${dateTime.month}';
      final weekday = getWeekdayName(dateTime.weekday);
      return '$day $month ${dateTime.year}, $weekday';
    }
  }

  /// Tarih Başlığı (Bugün, Dün, Yarın veya "Haftaya Çarşamba" / "04 Kasım, Çarşamba")
  static String formatRelativeHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Bugün ${getWeekdayName(date.weekday)}';
    if (diff == 1) return 'Yarın ${getWeekdayName(date.weekday)}';
    if (diff == -1) return 'Dün ${getWeekdayName(date.weekday)}';
    if (diff > 1 && diff <= 7) return 'Bu Hafta ${getWeekdayName(date.weekday)}';
    if (diff > 7 && diff <= 14) return 'Haftaya ${getWeekdayName(date.weekday)}';
    return getWeekdayName(date.weekday);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Günün saatine göre selamlama
  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 6 && hour < 12) {
      greeting = 'Günaydın';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'İyi günler';
    } else if (hour >= 18 && hour < 23) {
      greeting = 'İyi akşamlar';
    } else {
      greeting = 'İyi geceler';
    }
    return '$greeting, $name!';
  }

  /// Akıllı pencere kontrolü (varsayılan 18:00)
  static bool isWithinSmartWindow({int deadlineHour = 18, int deadlineMinute = 0}) {
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, deadlineHour, deadlineMinute);
    return now.isBefore(deadline);
  }

  /// Türkçe gün adı (1 = Pazartesi ... 7 = Pazar)
  static String getWeekdayName(int weekday) {
    if (weekday >= 1 && weekday <= 7) {
      return _turkishDays[weekday];
    }
    return '';
  }

  /// Kısa gün adı (Pzt, Sal, Çar...)
  static String getShortWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }
}
