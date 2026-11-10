import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService;

  String _userName = '';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isOnboardingDone = false;

  AppProvider(this._storageService) {
    _loadInitialState();
  }

  String get userName => _userName;
  ThemeMode get themeMode => _themeMode;
  bool get isOnboardingDone => _isOnboardingDone;

  void _loadInitialState() {
    _userName = _storageService.getUserName() ?? '';
    _themeMode = _storageService.getThemeMode();
    _isOnboardingDone = _storageService.isOnboardingDone();
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name.trim();
    await _storageService.setUserName(_userName);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> completeOnboarding(String name) async {
    _userName = name.trim();
    _isOnboardingDone = true;
    await _storageService.setUserName(_userName);
    await _storageService.setOnboardingDone(true);
    notifyListeners();
  }
}

