// lib/core/services/fcm_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (Android 13+ / iOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and store FCM token
    final token = await messaging.getToken();
    if (token != null) {
      await _storeToken(token);
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen(_storeToken);

    // Handle foreground messages (log only — no in-app notification for V1)
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print('[FCM] Foreground message: ${message.notification?.title}');
      }
    });
  }

  static Future<void> _storeToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}
