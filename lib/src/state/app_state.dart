import 'package:flutter/foundation.dart';

enum AppThemeMode {
  light,
  dark,
  highContrast,
}

class AppState extends ChangeNotifier {
  String deviceId = 'HARV-001';
  String harvesterId = 'HARVESTER-001';
  String farmerName = 'Farmer';
  String harvesterName = 'Harvester';
  AppThemeMode _themeMode = AppThemeMode.light;

  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == AppThemeMode.dark;
  bool get isHighContrast => _themeMode == AppThemeMode.highContrast;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleThemeMode() {
    switch (_themeMode) {
      case AppThemeMode.light:
        _themeMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        _themeMode = AppThemeMode.highContrast;
        break;
      case AppThemeMode.highContrast:
        _themeMode = AppThemeMode.light;
        break;
    }
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _themeMode = value ? AppThemeMode.dark : AppThemeMode.light;
    notifyListeners();
  }

  void setDeviceId(String id) {
    deviceId = id;
    notifyListeners();
  }

  void setHarvesterId(String id) {
    harvesterId = id;
    notifyListeners();
  }

  void setFarmerName(String name) {
    farmerName = name;
    notifyListeners();
  }

  void setHarvesterName(String name) {
    harvesterName = name;
    notifyListeners();
  }
}
