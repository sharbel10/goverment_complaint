import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../main.dart';

enum AppSnackType { success, error, warning, info }

void showAppSnack({
  required String title,
  required String message,
  AppSnackType type = AppSnackType.error,
  Duration duration = const Duration(seconds: 3),
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final messenger = rootMessengerKey.currentState;
    if (messenger == null) return;

    final theme = messenger.context.theme;
    final style = _SnackStyle.fromType(type, theme);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: style.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: style.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(style.icon, color: style.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.trim().isNotEmpty)
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: style.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (title.trim().isNotEmpty) const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: style.text.withOpacity(0.95),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => messenger.hideCurrentSnackBar(),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close, color: style.text, size: 18),
                ),
              ),
            ],
          ),
        ),
      );
  });
}

class _SnackStyle {
  final Color bg;
  final Color text;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  _SnackStyle({
    required this.bg,
    required this.text,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  factory _SnackStyle.fromType(AppSnackType type, ThemeData theme) {
    late final Color base;
    late final IconData icon;

    switch (type) {
      case AppSnackType.success:
        base = const Color(0xFF16A34A); // green
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackType.warning:
        base = const Color(0xFFF59E0B); // orange
        icon = Icons.warning_amber_rounded;
        break;
      case AppSnackType.info:
        base = const Color(0xFF2563EB); // blue
        icon = Icons.info_rounded;
        break;
      case AppSnackType.error:
      default:
        base = const Color(0xFFDC2626); // red
        icon = Icons.error_rounded;
        break;
    }

    final isDark = theme.brightness == Brightness.dark;

    return _SnackStyle(
      bg: isDark ? base.withOpacity(0.92) : base,
      text: Colors.white,
      icon: icon,
      iconBg: Colors.white.withOpacity(0.18),
      iconColor: Colors.white,
    );
  }
}
