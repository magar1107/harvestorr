import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/alert_card.dart';
import '../theme/app_colors.dart';
import '../services/firebase_service.dart';

class DashboardProvider extends ChangeNotifier {
  // Firebase references
  late DatabaseReference _metricsRef;
  late DatabaseReference _systemStatusRef;
  late Stream<DatabaseEvent> _metricsStream;
  late Stream<DatabaseEvent> _systemStatusStream;

  // Alerts
  List<AlertItem> _alerts = [];
  int _unreadAlertsCount = 0;

  // Metrics data from Firebase
  Map<String, double> _metrics = {
    'grainTank': 0.0,
    'ptoRpm': 0.0,
    'engineTemp': 0.0,
    'fuelLevel': 0.0,
  };

  // System status from Firebase
  Map<String, bool> _systemStatus = {
    'firebase': false,
    'sensors': false,
    'gps': false,
    'network': false,
  };

  // Loading states
  bool _isLoading = true;
  bool _isDarkMode = false;
  String _deviceId = 'HARVESTER-001';

  // Getters
  List<AlertItem> get alerts => _alerts;
  int get unreadAlertsCount => _unreadAlertsCount;
  Map<String, double> get metrics => _metrics;
  Map<String, bool> get systemStatus => _systemStatus;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  // Initialize with Firebase data
  DashboardProvider() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    _isLoading = true;
    notifyListeners();

    // Get device ID from context (will be set by the dashboard screen)
    _setupFirebaseListeners();
    _loadInitialData();
  }

  void _setupFirebaseListeners() {
    // Listen to metrics changes
    _metricsRef = FirebaseDatabase.instance.ref('devices/$_deviceId/metrics');
    _metricsStream = _metricsRef.onValue;

    _metricsStream.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _metrics = {
          'grainTank': (data['grainTank'] as num?)?.toDouble() ?? 0.0,
          'ptoRpm': (data['ptoRpm'] as num?)?.toDouble() ?? 0.0,
          'engineTemp': (data['engineTemp'] as num?)?.toDouble() ?? 0.0,
          'fuelLevel': (data['fuelLevel'] as num?)?.toDouble() ?? 0.0,
        };
        notifyListeners();
      }
    });

    // Listen to system status changes
    _systemStatusRef = FirebaseDatabase.instance.ref('devices/$_deviceId/systemStatus');
    _systemStatusStream = _systemStatusRef.onValue;

    _systemStatusStream.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _systemStatus = {
          'firebase': data['firebase'] as bool? ?? false,
          'sensors': data['sensors'] as bool? ?? false,
          'gps': data['gps'] as bool? ?? false,
          'network': data['network'] as bool? ?? false,
        };
        notifyListeners();
      }
    });
  }

  void _loadInitialData() async {
    try {
      // Load initial data from Firebase
      final deviceData = await FirebaseService.getDeviceData(_deviceId);

      if (deviceData['metrics'] != null) {
        _metrics = Map<String, double>.from(deviceData['metrics']);
      }

      if (deviceData['systemStatus'] != null) {
        _systemStatus = Map<String, bool>.from(deviceData['systemStatus']);
      }

      // Load alerts from Firebase (for now using sample data)
      await _loadAlerts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading initial data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAlerts() async {
    try {
      // This would typically use FirebaseService.getAlertsStream
      // For now, using sample data
      _alerts = [
        AlertItem(
          id: '1',
          title: 'Grain Tank Nearly Full',
          message: 'Grain tank capacity is at 85%. Consider unloading soon to maintain optimal performance.',
          severity: AlertSeverity.warning,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          deviceId: _deviceId,
        ),
        AlertItem(
          id: '2',
          title: 'Engine Temperature High',
          message: 'Engine temperature has reached 95°C. Please check cooling system.',
          severity: AlertSeverity.error,
          timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
          isRead: false,
          deviceId: _deviceId,
        ),
      ];

      _unreadAlertsCount = _alerts.where((alert) => !alert.isRead).length;
    } catch (e) {
      print('Error loading alerts: $e');
    }
  }

  // Set device ID (called from dashboard screen)
  void setDeviceId(String deviceId) {
    if (_deviceId != deviceId) {
      _deviceId = deviceId;
      _initializeFirebase();
    }
  }

  // Update metrics (for testing/simulation)
  void updateMetric(String key, double value) {
    if (_metrics.containsKey(key)) {
      _metrics[key] = value;
      // Also update Firebase
      FirebaseService.updateMetric(_deviceId, key, value);
      notifyListeners();
    }
  }

  // Add new alert
  void addAlert(AlertItem alert) {
    _alerts.insert(0, alert);
    if (!alert.isRead) {
      _unreadAlertsCount++;
    }
    notifyListeners();
  }

  // Mark alert as read
  void markAlertAsRead(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index] = AlertItem(
        id: _alerts[index].id,
        title: _alerts[index].title,
        message: _alerts[index].message,
        severity: _alerts[index].severity,
        timestamp: _alerts[index].timestamp,
        isRead: true,
        deviceId: _alerts[index].deviceId,
      );
      _unreadAlertsCount = _alerts.where((alert) => !alert.isRead).length;
      notifyListeners();
    }
  }

  // Mark all alerts as read
  void markAllAlertsAsRead() {
    for (int i = 0; i < _alerts.length; i++) {
      if (!_alerts[i].isRead) {
        _alerts[i] = AlertItem(
          id: _alerts[i].id,
          title: _alerts[i].title,
          message: _alerts[i].message,
          severity: _alerts[i].severity,
          timestamp: _alerts[i].timestamp,
          isRead: true,
          deviceId: _alerts[i].deviceId,
        );
      }
    }
    _unreadAlertsCount = 0;
    notifyListeners();
  }

  // Update system status
  void updateSystemStatus(String system, bool isOnline) {
    if (_systemStatus.containsKey(system)) {
      _systemStatus[system] = isOnline;
      // Also update Firebase
      FirebaseService.updateSystemStatus(_deviceId, system, isOnline);
      notifyListeners();
    }
  }

  // Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Get metric value with unit
  String getMetricValue(String key) {
    final value = _metrics[key];
    if (value == null) return '0';

    switch (key) {
      case 'grainTank':
      case 'fuelLevel':
        return value.round().toString();
      case 'ptoRpm':
        return value.round().toString();
      case 'engineTemp':
        return value.round().toString();
      default:
        return value.toStringAsFixed(1);
    }
  }

  // Get metric unit
  String getMetricUnit(String key) {
    switch (key) {
      case 'grainTank':
      case 'fuelLevel':
        return '%';
      case 'ptoRpm':
        return 'RPM';
      case 'engineTemp':
        return '°C';
      default:
        return '';
    }
  }

  // Get metric progress value for progress bars
  double getMetricProgress(String key) {
    final value = _metrics[key];
    if (value == null) return 0.0;

    switch (key) {
      case 'grainTank':
      case 'fuelLevel':
        return value / 100.0;
      case 'ptoRpm':
        return value / 1000.0;
      case 'engineTemp':
        return value / 120.0;
      default:
        return 0.0;
    }
  }

  // Get metric color based on value and type
  Color getMetricColor(String key) {
    final value = _metrics[key];
    if (value == null) return AppColors.primary;

    switch (key) {
      case 'grainTank':
      case 'fuelLevel':
        if (value < 30) return AppColors.error;
        if (value < 70) return AppColors.warning;
        return AppColors.success;
      case 'ptoRpm':
        return AppColors.secondary;
      case 'engineTemp':
        if (value > 90) return AppColors.error;
        if (value > 80) return AppColors.warning;
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  // Get last updated timestamp
  String getLastUpdated() {
    // Return current time since we're getting real-time updates
    final now = DateTime.now();
    final difference = DateTime.now().difference(now);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
  }

  @override
  void dispose() {
    // Clean up streams if needed
    super.dispose();
  }
}
