import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LocaleService extends GetxService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _key = 'locale_lang';

  Locale get locale => _locale;
  Locale _locale = const Locale('ar', 'SY');

  Future<LocaleService> init() async {
    String? langCode = await _storage.read(key: _key);
    if (langCode != null) {
      if (langCode == 'en') {
        _locale = const Locale('en', 'US');
      } else {
        _locale = const Locale('ar', 'SY');
      }
    }
    return this;
  }

  Future<void> changeLocale(String languageCode) async {
    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('ar', 'SY');
    }
    await Get.updateLocale(_locale);
    await _storage.write(key: _key, value: languageCode);
  }
}
