import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  // Local stream of notifications for mock triggers
  final StreamController<NotificationModel> _notificationStreamController = 
      StreamController<NotificationModel>.broadcast();
  
  Stream<NotificationModel> get notificationStream => _notificationStreamController.stream;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    try {
      // 1. Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // 2. Obtain token (useful for real server integration later)
      String? token = await _fcm.getToken();
      print("FCM Token: $token");

      // 3. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          final newNotification = NotificationModel(
            id: message.messageId ?? DateTime.now().toIso8601String(),
            title: message.notification!.title ?? 'New Update',
            body: message.notification!.body ?? '',
            timestamp: DateTime.now(),
            type: 'fcm',
          );
          _notificationStreamController.add(newNotification);
        }
      });

      // 4. Background click listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification clicked from background: ${message.data}");
      });
      
    } catch (e) {
      print("Firebase Messaging not initialized (likely running local mock mode): $e");
    }
  }

  // Trigger Mock Notification (Client-side simulation for resume showcase)
  void simulateNotification({required String title, required String body, required String type}) {
    final mockNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );
    _notificationStreamController.add(mockNotification);
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
