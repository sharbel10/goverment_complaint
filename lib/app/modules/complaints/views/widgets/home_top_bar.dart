import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goverment_complaints/app/modules/auth/views/pages/notification_page_view.dart';
import 'package:goverment_complaints/app/services/locale_service.dart';
import 'package:goverment_complaints/app/services/theme_service.dart';

class HomeTopBar extends StatelessWidget {
  final void Function() onPressed;
  const HomeTopBar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: onPressed,
        ),
        IconButton(
          icon: Icon(
            Icons.language,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: () {
            final localeService = Get.find<LocaleService>();
            if (Get.locale?.languageCode == 'en') {
              localeService.changeLocale('ar');
            } else {
              localeService.changeLocale('en');
            }
          },
        ),
        IconButton(
          icon: Icon(
            Get.find<ThemeService>().themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: Get.find<ThemeService>().switchTheme,
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.notifications_active,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: () => Get.to(() => const NotificationsView()),
        ),
      ],
    );
  }
}
