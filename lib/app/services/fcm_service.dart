import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class FcmService {
  final ApiService _api;
  final FlutterSecureStorage _storage;

  FcmService(this._api, this._storage);

  Future<void> initAndSyncToken() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission(alert: true, badge: true, sound: true);

    final token = await fcm.getToken();
    if (token != null && token.isNotEmpty) {
      await _sendToken(token);
    }

    fcm.onTokenRefresh.listen((newToken) async {
      await _sendToken(newToken);
    });
  }

  Future<void> _sendToken(String token) async {
    final citizenId = await _storage.read(key: 'citizen_id');

    debugPrint('FCM DEBUG -> citizenId: $citizenId');
    debugPrint('FCM DEBUG -> token length: ${token.length}');
    debugPrint('FCM DEBUG -> token: $token'); // مؤقت فقط

    if (citizenId == null || citizenId.isEmpty) {
      debugPrint('FCM: citizen_id not found -> skip token sync');
      return;
    }

    try {
      debugPrint('FCM DEBUG -> sending body: { fcm_token: $token }');

      await _api.post(
        'fcm_token/$citizenId',
        data: {
          'fcm_token': token,
        },
      );

      debugPrint('FCM: token synced ✅');
    } catch (e) {
      debugPrint('FCM: token sync failed ❌ $e');
    }
  }

}
