import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';

/// Provider para gerenciar tema da aplicação
class ThemeProvider extends ChangeNotifier {
  final StorageService storageService;

  ThemeProvider({required this.storageService}) {
    _loadThemeMode();
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Carrega tema salvo
  Future<void> _loadThemeMode() async {
    final savedTheme = storageService.getThemeMode();
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }

  /// Alterna para tema claro
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await storageService.saveThemeMode('light');
    notifyListeners();
  }

  /// Alterna para tema escuro
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await storageService.saveThemeMode('dark');
    notifyListeners();
  }

  /// Alterna para tema do sistema
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    await storageService.saveThemeMode('system');
    notifyListeners();
  }

  /// Alterna entre claro e escuro
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }
}
