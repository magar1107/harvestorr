import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  Future<void> initFCM({required String uid, String? webVapidKey}) async {
    await _initLocalNotifications();
    await _requestPermission();
    String? token;
    if (kIsWeb) {
      token = await _messaging.getToken(vapidKey: webVapidKey);
    } else {
      token = await _messaging.getToken();
    }
    if (token != null) {
      await FirebaseDatabase.instance
          .ref('notifications/deviceTokens/$uid/$token')
          .set(true);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // In-app handling can be added by caller via callbacks or a global key
      debugPrint('FCM message: ${message.notification?.title} - ${message.notification?.body}');
      _showLocalNotification(message);
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _fln.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'harvestor_alerts',
      'Harvester Alerts',
      description: 'Critical and warning alerts from the harvester',
      importance: Importance.high,
    );
    await _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'harvestor_alerts',
        'Harvester Alerts',
        channelDescription: 'Critical and warning alerts from the harvester',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _fln.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      notification.title,
      notification.body,
      details,
    );
  }
}
