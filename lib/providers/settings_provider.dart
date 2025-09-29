import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../src/state/app_state.dart';

class SettingsProvider extends ChangeNotifier {
  // Firebase references
  late DatabaseReference _settingsRef;
  late DatabaseReference _deviceHistoryRef;
  late Stream<DatabaseEvent> _settingsStream;
  late Stream<DatabaseEvent> _deviceHistoryStream;

  // Profile data
  String _farmerName = '';
  String _harvesterName = '';
  String _deviceId = '';

  // Device status history
  List<Map<String, dynamic>> _deviceHistory = [];

  // Alert preferences
  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _vibrationAlerts = true;
  double _alertVolume = 0.7;
  String _selectedAlertSound = 'Default';

  // UI states
  bool _isLoading = false;
  DateTime? _lastSavedTime;

  // Getters
  String get farmerName => _farmerName;
  String get harvesterName => _harvesterName;
  String get deviceId => _deviceId;
  List<Map<String, dynamic>> get deviceHistory => _deviceHistory;
  bool get pushNotifications => _pushNotifications;
  bool get soundAlerts => _soundAlerts;
  bool get vibrationAlerts => _vibrationAlerts;
  double get alertVolume => _alertVolume;
  String get selectedAlertSound => _selectedAlertSound;
  bool get isLoading => _isLoading;
  DateTime? get lastSavedTime => _lastSavedTime;

  // Initialize with Firebase data
  SettingsProvider() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        _settingsRef = FirebaseDatabase.instance.ref('users/${user.uid}/settings');
        _deviceHistoryRef = FirebaseDatabase.instance.ref('users/${user.uid}/deviceHistory');

        _loadSettingsFromFirebase();
        _loadDeviceHistoryFromFirebase();

        // Listen for real-time updates
        _settingsStream = _settingsRef.onValue;
        _settingsStream.listen((event) {
          if (event.snapshot.exists) {
            _loadSettingsFromSnapshot(event.snapshot);
          }
        });

        _deviceHistoryStream = _deviceHistoryRef.onValue;
        _deviceHistoryStream.listen((event) {
          if (event.snapshot.exists) {
            _loadDeviceHistoryFromSnapshot(event.snapshot);
          }
        });
      } else {
        print('SettingsProvider: No authenticated user found');
        // Set default values when no user is authenticated
        _setDefaultValues();
      }
    } catch (e) {
      print('SettingsProvider initialization error: $e');
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    _farmerName = 'John Farmer';
    _harvesterName = 'Harvester Pro 5000';
    _deviceId = 'HARVESTER-001';
    _deviceHistory = [
      {'time': 'Just now', 'status': 'Online', 'icon': Icons.wifi, 'color': Colors.green},
    ];
    notifyListeners();
  }

  void _loadSettingsFromFirebase() async {
    try {
      setLoading(true);
      final snapshot = await _settingsRef.get();
      if (snapshot.exists) {
        _loadSettingsFromSnapshot(snapshot);
      } else {
        // Create default settings if none exist
        await _createDefaultSettings();
      }
    } catch (e) {
      print('Error loading settings from Firebase: $e');
    } finally {
      setLoading(false);
    }
  }

  void _loadDeviceHistoryFromFirebase() async {
    try {
      final snapshot = await _deviceHistoryRef.get();
      if (snapshot.exists) {
        _loadDeviceHistoryFromSnapshot(snapshot);
      }
    } catch (e) {
      print('Error loading device history from Firebase: $e');
    }
  }

  void _loadSettingsFromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      _farmerName = data['farmerName']?.toString() ?? '';
      _harvesterName = data['harvesterName']?.toString() ?? '';
      _deviceId = data['deviceId']?.toString() ?? '';

      // Update AppState if available
      try {
        // We'll let the SettingsScreen handle AppState updates
        // to ensure proper context and error handling
      } catch (e) {
        print('Could not update AppState from Firebase: $e');
      }

      // Alert preferences
      _pushNotifications = data['pushNotifications'] ?? true;
      _soundAlerts = data['soundAlerts'] ?? true;
      _vibrationAlerts = data['vibrationAlerts'] ?? true;
      _alertVolume = (data['alertVolume'] ?? 0.7).toDouble();
      _selectedAlertSound = data['selectedAlertSound']?.toString() ?? 'Default';

      notifyListeners();
    }
  }

  void _loadDeviceHistoryFromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      _deviceHistory = [];

      data.forEach((key, value) {
        if (value is Map) {
          _deviceHistory.add({
            'id': key,
            'time': value['timestamp']?.toString() ?? '',
            'status': value['status']?.toString() ?? 'Unknown',
            'icon': _getStatusIcon(value['status']?.toString() ?? 'Unknown'),
            'color': _getStatusColor(value['status']?.toString() ?? 'Unknown'),
          });
        }
      });

      // Sort by timestamp (newest first)
      _deviceHistory.sort((a, b) =>
        DateTime.parse(b['time']).compareTo(DateTime.parse(a['time']))
      );

      // Keep only last 10 entries
      if (_deviceHistory.length > 10) {
        _deviceHistory = _deviceHistory.take(10).toList();
      }

      notifyListeners();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Icons.wifi;
      case 'offline':
        return Icons.wifi_off;
      case 'maintenance':
        return Icons.build;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Future<void> _createDefaultSettings() async {
    try {
      await _settingsRef.set({
        'farmerName': 'John Farmer',
        'harvesterName': 'Harvester Pro 5000',
        'deviceId': 'HARVESTER-001',
        'pushNotifications': true,
        'soundAlerts': true,
        'vibrationAlerts': true,
        'alertVolume': 0.7,
        'selectedAlertSound': 'Default',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating default settings: $e');
    }
  }

  Future<void> saveProfileSettings(String farmerName, String harvesterName, String deviceId) async {
    try {
      setLoading(true);

      if (_settingsRef.key?.isEmpty ?? true) {
        throw Exception('Settings reference not initialized');
      }

      await _settingsRef.update({
        'farmerName': farmerName,
        'harvesterName': harvesterName,
        'deviceId': deviceId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local values
      _farmerName = farmerName;
      _harvesterName = harvesterName;
      _deviceId = deviceId;
      _lastSavedTime = DateTime.now();

      // Update AppState as well
      try {
        // Get the AppState from the context if available
        // For now, we'll rely on the settings screen to update AppState
      } catch (e) {
        print('Could not update AppState: $e');
      }

      notifyListeners();
    } catch (e) {
      print('Error saving profile settings: $e');
      // Don't throw error, just log it and keep local changes
      _farmerName = farmerName;
      _harvesterName = harvesterName;
      _deviceId = deviceId;
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveAlertPreferences({
    bool? pushNotifications,
    bool? soundAlerts,
    bool? vibrationAlerts,
    double? alertVolume,
    String? selectedAlertSound,
  }) async {
    try {
      setLoading(true);

      final updates = <String, dynamic>{};
      if (pushNotifications != null) updates['pushNotifications'] = pushNotifications;
      if (soundAlerts != null) updates['soundAlerts'] = soundAlerts;
      if (vibrationAlerts != null) updates['vibrationAlerts'] = vibrationAlerts;
      if (alertVolume != null) updates['alertVolume'] = alertVolume;
      if (selectedAlertSound != null) updates['selectedAlertSound'] = selectedAlertSound;

      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _settingsRef.update(updates);

      // Update local values
      if (pushNotifications != null) _pushNotifications = pushNotifications;
      if (soundAlerts != null) _soundAlerts = soundAlerts;
      if (vibrationAlerts != null) _vibrationAlerts = vibrationAlerts;
      if (alertVolume != null) _alertVolume = alertVolume;
      if (selectedAlertSound != null) _selectedAlertSound = selectedAlertSound;

      notifyListeners();
    } catch (e) {
      print('Error saving alert preferences: $e');
      throw e;
    } finally {
      setLoading(false);
    }
  }

  Future<void> addDeviceStatusEntry(String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newEntry = {
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
          'deviceId': _deviceId,
        };

        await _deviceHistoryRef.push().set(newEntry);
      }
    } catch (e) {
      print('Error adding device status entry: $e');
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Method to reinitialize when user logs in
  void reinitializeForUser() {
    _initializeFirebase();
  }

  // Method to sync with AppState (called from SettingsScreen)
  void syncWithAppState(AppState appState) {
    if (_farmerName.isNotEmpty) {
      appState.setFarmerName(_farmerName);
    }
    if (_harvesterName.isNotEmpty) {
      appState.setHarvesterName(_harvesterName);
    }
    if (_deviceId.isNotEmpty) {
      appState.setDeviceId(_deviceId);
    }
  }
  // Method to check if provider is properly initialized
  bool get isInitialized => _settingsRef.key?.isNotEmpty ?? false;
}
