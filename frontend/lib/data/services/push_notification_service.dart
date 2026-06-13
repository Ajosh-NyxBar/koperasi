import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

/// Handler untuk background messages (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background message sudah otomatis ditampilkan sebagai notification oleh sistem
}

class PushNotificationService {
  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'kbmt_high_importance',
    'KBMT Notifikasi',
    description: 'Notifikasi penting dari KBMT',
    importance: Importance.high,
  );

  PushNotificationService(this._ref);

  /// Inisialisasi FCM dan local notifications
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notification permission denied');
      return;
    }

    // Setup local notifications untuk foreground
    await _setupLocalNotifications();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap (app terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and register token
    await _registerToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _sendTokenToServer(token);
    });
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap dari local notification
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _navigateFromPayload(data);
        }
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _registerToken() async {
    try {
      String? token;
      if (Platform.isIOS) {
        // Untuk iOS, perlu APNS token dulu
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          token = await _messaging.getToken();
        }
      } else {
        token = await _messaging.getToken();
      }

      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final dio = _ref.read(dioProvider);
      await dio.post('${ApiConstants.deviceTokens}', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('Error sending token to server: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Tampilkan sebagai local notification
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    // Navigate berdasarkan tipe notifikasi
    // Implementasi navigasi bisa ditambahkan sesuai kebutuhan
    // Contoh: data['type'] == 'financing_approved' -> navigate ke detail pembiayaan
    debugPrint('Notification tapped with data: $data');
  }

  /// Hapus token saat logout
  Future<void> removeToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        final dio = _ref.read(dioProvider);
        await dio.delete('${ApiConstants.deviceTokens}', data: {'token': token});
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }
}
