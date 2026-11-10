import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/archived_term_model.dart';

class StorageService {
  static const String _keyUserName = 'kou_user_name';
  static const String _keyThemeMode = 'kou_theme_mode';
  static const String _keyCourses = 'kou_courses_list';
  static const String _keyArchivedTerms = 'kou_archived_terms';
  static const String _keyOnboardingDone = 'kou_onboarding_done';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Kullanıcı Bilgisi ---
  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  Future<bool> setUserName(String name) async {
    return await _prefs.setString(_keyUserName, name);
  }

  // --- Onboarding Durumu ---
  bool isOnboardingDone() {
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<bool> setOnboardingDone(bool isDone) async {
    return await _prefs.setBool(_keyOnboardingDone, isDone);
  }

  // --- Tema Tercihi ---
  ThemeMode getThemeMode() {
    final themeStr = _prefs.getString(_keyThemeMode);
    if (themeStr == 'dark') return ThemeMode.dark;
    if (themeStr == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    String strVal = 'system';
    if (mode == ThemeMode.dark) strVal = 'dark';
    if (mode == ThemeMode.light) strVal = 'light';
    return await _prefs.setString(_keyThemeMode, strVal);
  }

  // --- Dersler (Courses) ---
  List<CourseModel> getCourses() {
    final rawJson = _prefs.getString(_keyCourses);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => CourseModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Dersler parse edilirken hata: $e');
      return [];
    }
  }

  Future<bool> saveCourses(List<CourseModel> courses) async {
    try {
      final rawJson = jsonEncode(courses.map((c) => c.toJson()).toList());
      return await _prefs.setString(_keyCourses, rawJson);
    } catch (e) {
      debugPrint('Dersler kaydedilirken hata: $e');
      return false;
    }
  }

  // --- Geçmiş / Arşiv (Archived Terms) ---
  List<ArchivedTermModel> getArchivedTerms() {
    final rawJson = _prefs.getString(_keyArchivedTerms);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => ArchivedTermModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Arşiv parse edilirken hata: $e');
      return [];
    }
  }

  Future<bool> saveArchivedTerms(List<ArchivedTermModel> terms) async {
    try {
      final rawJson = jsonEncode(terms.map((t) => t.toJson()).toList());
      return await _prefs.setString(_keyArchivedTerms, rawJson);
    } catch (e) {
      debugPrint('Arşiv kaydedilirken hata: $e');
      return false;
    }
  }

  /// Tüm verileri temizleme (Geliştirici veya tam sıfırlama için)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

