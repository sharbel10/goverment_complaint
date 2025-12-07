import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/services/api_service.dart';
import 'package:goverment_complaints/app/services/network_service.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NetworkService networkService = Get.put(
    NetworkService(),
    permanent: true,
  );
  final apiService = ApiService(
    baseUrl: 'http://10.0.2.2:8000/api/',
    networkService: networkService,
  );

  Get.put<ApiService>(apiService, permanent: true);
  final secureStorage = const FlutterSecureStorage();
  final savedToken = await secureStorage.read(key: 'auth_token');
  if (savedToken != null && savedToken.isNotEmpty) {
    apiService.setAuthToken(savedToken);
  }
  final initialRoute =
      (savedToken != null && savedToken.isNotEmpty)
          ? AppRoutes.home
          : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
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
