import 'package:firebase_database/firebase_database.dart';
import '../widgets/alert_card.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Real-time listeners
  static Stream<DatabaseEvent> getMetricsStream(String deviceId) {
    return _database.ref('devices/$deviceId/metrics').onValue;
  }

  static Stream<DatabaseEvent> getAlertsStream(String deviceId) {
    return _database.ref('devices/$deviceId/alerts').onValue;
  }

  static Stream<DatabaseEvent> getSystemStatusStream(String deviceId) {
    return _database.ref('devices/$deviceId/systemStatus').onValue;
  }

  static Stream<DatabaseEvent> getDeviceStatusStream(String deviceId) {
    return _database.ref('devices/$deviceId/status').onValue;
  }

  // Methods to update data in Firebase
  static Future<void> updateMetric(String deviceId, String metricKey, double value) async {
    try {
      await _database.ref('devices/$deviceId/metrics/$metricKey').set(value);
    } catch (e) {
      print('Error updating metric: $e');
      rethrow;
    }
  }

  static Future<void> addAlert(String deviceId, AlertItem alert) async {
    try {
      await _database.ref('devices/$deviceId/alerts/${alert.id}').set({
        'id': alert.id,
        'title': alert.title,
        'message': alert.message,
        'severity': alert.severity.toString(),
        'timestamp': ServerValue.timestamp,
        'isRead': alert.isRead,
        'deviceId': alert.deviceId,
      });
    } catch (e) {
      print('Error adding alert: $e');
      rethrow;
    }
  }

  static Future<void> markAlertAsRead(String deviceId, String alertId) async {
    try {
      await _database.ref('devices/$deviceId/alerts/$alertId/isRead').set(true);
    } catch (e) {
      print('Error marking alert as read: $e');
      rethrow;
    }
  }

  static Future<void> updateSystemStatus(String deviceId, String system, bool isOnline) async {
    try {
      await _database.ref('devices/$deviceId/systemStatus/$system').set(isOnline);
    } catch (e) {
      print('Error updating system status: $e');
      rethrow;
    }
  }

  // Get initial data
  static Future<Map<String, dynamic>> getDeviceData(String deviceId) async {
    try {
      final metricsSnapshot = await _database.ref('devices/$deviceId/metrics').get();
      final statusSnapshot = await _database.ref('devices/$deviceId/systemStatus').get();
      final deviceSnapshot = await _database.ref('devices/$deviceId/status').get();

      return {
        'metrics': metricsSnapshot.value as Map<dynamic, dynamic>? ?? {},
        'systemStatus': statusSnapshot.value as Map<dynamic, dynamic>? ?? {},
        'deviceStatus': deviceSnapshot.value as Map<dynamic, dynamic>? ?? {},
      };
    } catch (e) {
      print('Error getting device data: $e');
      rethrow;
    }
  }

  // Simulate real-time data updates for testing
  static void startDataSimulation(String deviceId) {
    // Simulate metric updates
    Future.delayed(const Duration(seconds: 3), () {
      updateMetric(deviceId, 'grainTank', 52.0);
      updateMetric(deviceId, 'engineTemp', 88.0);
    });

    Future.delayed(const Duration(seconds: 8), () {
      updateSystemStatus(deviceId, 'gps', true);
    });

    Future.delayed(const Duration(seconds: 15), () {
      addAlert(deviceId, AlertItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Fuel Level Low',
        message: 'Fuel level has dropped below 20%. Please refuel soon.',
        severity: AlertSeverity.warning,
        timestamp: DateTime.now(),
        deviceId: deviceId,
        isRead: false,
      ));
    });
  }
}
