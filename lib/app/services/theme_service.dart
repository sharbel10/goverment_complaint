import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  static const Color brandDark = Color(0xFF002623);
  static const Color brandGold = Color(0xFFb9a779);
  static const Color brandCardDark = Color(0xFF003832);
  static const Color textLight = Color.fromARGB(255, 82, 82, 79);
  static const Color lightBackground = Color(0xFF003832);

  Future<ThemeService> init() async {
    String? themeString = await _storage.read(key: _key);
    if (themeString != null) {
      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    } else {
      _themeMode = ThemeMode.dark;
    }
    Get.changeThemeMode(_themeMode);
    return this;
  }

  void switchTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _storage.write(key: _key, value: 'dark');
    } else {
      _themeMode = ThemeMode.light;
      _storage.write(key: _key, value: 'light');
    }
    Get.changeThemeMode(_themeMode);
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: brandDark,
    primaryColor: brandGold,
    cardColor: brandCardDark,
    iconTheme: const IconThemeData(color: Colors.white70), // أيقونات ظاهرة
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      bodyLarge: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: brandGold, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brandCardDark,
      hintStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIconColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandGold,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: brandGold),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: brandGold,
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: brandDark,
      secondary: brandGold,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      bodyLarge: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: brandDark, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandGold, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandGold,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: brandGold),
    ),
  );
}
