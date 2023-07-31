import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebasePushConnector extends PushConnector {
  static FirebaseMessaging get firebase => FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier<bool?>(null);

  @override
  Future<void> configure({
    MessageHandler? onMessage,
    MessageHandler? onLaunch,
    MessageHandler? onResume,
    MessageHandler? onBackgroundMessage,
    FirebaseMessageHandler? onBackgroundMessageFirebase,
  }) async {
    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });

    FirebaseMessaging.onMessage.listen((data) => onMessage?.call(data.toMap()));
    FirebaseMessaging.onMessageOpenedApp
        .listen((data) => onResume?.call(data.toMap()));

    if (onBackgroundMessageFirebase != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageFirebase);
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onLaunch?.call(initial.toMap());
    }

    token.value = await firebase.getToken();
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() async {
    NotificationSettings permissions = await firebase.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (permissions.authorizationStatus.name == 'authorized') {
      isDisabledByUser.value = false;
    } else if (permissions.authorizationStatus.name == 'denied') {
      isDisabledByUser.value = true;
    }
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() async {
    await firebase.setAutoInitEnabled(false);
    await firebase.deleteToken();

    token.value = null;
  }
}
