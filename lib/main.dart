import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app/services/api_service.dart';
import 'app/services/network_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // إذا حابب تعالج إشعارات الباكغراوند لاحقاً
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 تهيئة Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 تهيئة flutter_local_notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 🔹 خدمات الشبكة و API
  final NetworkService networkService = Get.put(
    NetworkService(),
    permanent: true,
  );

  final apiService = ApiService(
    baseUrl: 'http://10.23.75.139:8000/api/',
    networkService: networkService,
  );

  Get.put<ApiService>(apiService, permanent: true);

  // 🔹 استرجاع توكن الدخول
  final secureStorage = const FlutterSecureStorage();
  final savedToken = await secureStorage.read(key: 'auth_token');
  if (savedToken != null && savedToken.isNotEmpty) {
    apiService.setAuthToken(savedToken);
  }

  // 🔹 تهيئة FCM
  await _initPushNotifications(apiService);

  final initialRoute = (savedToken != null && savedToken.isNotEmpty)
      ? AppRoutes.home
      : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> _initPushNotifications(ApiService apiService) async {
  final fcm = FirebaseMessaging.instance;

  // طلب صلاحيات
  await fcm.requestPermission();

  // الحصول على الـ FCM Token
  final token = await fcm.getToken();
  debugPrint('🔥 FCM TOKEN: $token');

  // إشعار والتطبيق مفتوح (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📩 onMessage: ${message.notification?.title}');

    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // المستخدم كبس على الإشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📩 onMessageOpenedApp: ${message.data}');
    final complaintId = message.data['complaint_id'];
    if (complaintId != null) {
      Get.toNamed('/complaint-details', arguments: complaintId);
    }
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Government Complaints Portal",
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF283593)),
      ),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
