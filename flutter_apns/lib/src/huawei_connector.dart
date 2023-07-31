import 'package:flutter/foundation.dart';
import 'package:flutter_apns/apns.dart';
import 'package:huawei_push/huawei_push.dart';

class HuaweiPushConnector extends PushConnector {
  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    Push.turnOnPush();
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() {
    return Push.deleteToken('');
  }

  @override
  Future<void> configure({
    MessageHandler? onMessage,
    MessageHandler? onLaunch,
    MessageHandler? onResume,
    MessageHandler? onBackgroundMessage,
    FirebaseMessageHandler? onBackgroundMessageFirebase,
  }) {
    Push.getTokenStream.listen((event) {
      token.value = event;
    }, onError: (error) {
      token.value = null;
    });

    Push.onMessageReceivedStream.listen(
      (event) {
        //[data] is string  while [dataOfMap] is Map :)
        onMessage?.call({
          "data": event.dataOfMap,
        });
      },
      onError: (error) {},
    );

    if (onBackgroundMessage != null) {
      Push.registerBackgroundMessageHandler((event) {
        onBackgroundMessage({
          "data": event.dataOfMap,
        });
      });
    }
    Push.getToken('');

    return Future.value();
  }
}
