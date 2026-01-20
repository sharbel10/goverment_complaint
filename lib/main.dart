import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:goverment_complaints/app/services/locale_service.dart';
import 'package:goverment_complaints/app/services/theme_service.dart';
import 'package:goverment_complaints/app/translations/messages.dart';

import 'app/modules/notifications/notifications_controller.dart';
import 'app/services/api_service.dart';
import 'app/services/network_service.dart';
import 'app/services/fcm_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {

}

final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse resp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(AppRoutes.notifications);
      });
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final NetworkService networkService =
  Get.put(NetworkService(), permanent: true);

  final apiService = ApiService(
    baseUrl: 'http://10.146.119.142:8000/api/',
    networkService: networkService,
  );

  Get.put<ApiService>(apiService, permanent: true);

  Get.put(NotificationsController(), permanent: true);

  const secureStorage = FlutterSecureStorage();
  final savedToken = await secureStorage.read(key: 'auth_token');
  if (savedToken != null && savedToken.isNotEmpty) {
    apiService.setAuthToken(savedToken);
  }

  await Get.putAsync(() => LocaleService().init());
  await Get.putAsync(() => ThemeService().init());

  await _initPushNotifications();

  await FcmService(apiService, secureStorage).initAndSyncToken();

  final initialRoute = (savedToken != null && savedToken.isNotEmpty)
      ? AppRoutes.home
      : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> _initPushNotifications() async {
  final fcm = FirebaseMessaging.instance;
  final notificationsCtrl = Get.find<NotificationsController>();

  await fcm.requestPermission(alert: true, badge: true, sound: true);

  const channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'Default notifications channel',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('FCM DEBUG (onMessage) -> data: ${message.data}');
    debugPrint('FCM DEBUG (onMessage) -> title: ${message.notification?.title}');
    debugPrint('FCM DEBUG (onMessage) -> body: ${message.notification?.body}');

    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

    if (title.isNotEmpty || body.isNotEmpty) {
      notificationsCtrl.addFromFcm(
        title: title,
        body: body,
        data: Map<String, dynamic>.from(message.data),
      );
    }

    final notif = message.notification;
    if (notif == null) return;

    await flutterLocalNotificationsPlugin.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: 'open_notifications',
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('FCM DEBUG (onOpen) -> data: ${message.data}');
    debugPrint('FCM DEBUG (onOpen) -> title: ${message.notification?.title}');
    debugPrint('FCM DEBUG (onOpen) -> body: ${message.notification?.body}');

    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

    if (title.isNotEmpty || body.isNotEmpty) {
      notificationsCtrl.addFromFcm(
        title: title,
        body: body,
        data: Map<String, dynamic>.from(message.data),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(AppRoutes.notifications);
      // أو: Get.offAllNamed(AppRoutes.notifications);
    });
  });

  final initialMessage = await fcm.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('FCM DEBUG (initial) -> data: ${initialMessage.data}');
    debugPrint(
        'FCM DEBUG (initial) -> title: ${initialMessage.notification?.title}');
    debugPrint(
        'FCM DEBUG (initial) -> body: ${initialMessage.notification?.body}');

    final title = initialMessage.notification?.title ?? '';
    final body = initialMessage.notification?.body ?? '';

    if (title.isNotEmpty || body.isNotEmpty) {
      notificationsCtrl.addFromFcm(
        title: title,
        body: body,
        data: Map<String, dynamic>.from(initialMessage.data),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(AppRoutes.notifications);
      // أو: Get.offAllNamed(AppRoutes.notifications);
    });
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 730),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          scaffoldMessengerKey: rootMessengerKey,
          debugShowCheckedModeBanner: false,
          title: "Government Complaints Portal",
          translations: Messages(),
          locale: Get.find<LocaleService>().locale,
          fallbackLocale: const Locale('en', 'US'),
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: Get.find<ThemeService>().themeMode,
          initialRoute: initialRoute,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
