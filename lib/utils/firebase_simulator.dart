import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';

class FirebaseDataSimulator {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static Timer? _timer;

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Start simulating real-time data
    startDataSimulation('HARVESTER-001');
  }

  static void startDataSimulation(String deviceId) {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateMetrics(deviceId);
      _updateSystemStatus(deviceId);
    });
  }

  static void stopSimulation() {
    _timer?.cancel();
  }

  static void _updateMetrics(String deviceId) {
    final Random random = Random();

    // Simulate realistic metric changes
    final grainTank = 45 + random.nextDouble() * 40; // 45-85%
    final ptoRpm = 500 + random.nextDouble() * 100; // 500-600 RPM
    final engineTemp = 75 + random.nextDouble() * 20; // 75-95°C
    final fuelLevel = 60 + random.nextDouble() * 35; // 60-95%

    _database.child('devices/$deviceId/metrics').set({
      'grainTank': grainTank,
      'ptoRpm': ptoRpm,
      'engineTemp': engineTemp,
      'fuelLevel': fuelLevel,
      'timestamp': ServerValue.timestamp,
    });
  }

  static void _updateSystemStatus(String deviceId) {
    final Random random = Random();

    // Simulate system status changes
    _database.child('devices/$deviceId/systemStatus').set({
      'firebase': true,
      'sensors': random.nextBool(),
      'gps': random.nextDouble() > 0.1, // 90% uptime
      'network': random.nextDouble() > 0.05, // 95% uptime
      'timestamp': ServerValue.timestamp,
    });
  }

  // Method to add test alerts
  static void addTestAlert(String deviceId) {
    _database.child('devices/$deviceId/alerts').push().set({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Test Alert',
      'message': 'This is a test alert from Firebase simulation',
      'severity': 'info',
      'timestamp': ServerValue.timestamp,
      'isRead': false,
      'deviceId': deviceId,
    });
  }
}
