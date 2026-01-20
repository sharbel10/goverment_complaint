import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'models/app_notifications.dart';

class NotificationsController extends GetxController {
  static const _key = 'app_notifications';
  final _box = GetStorage();

  final RxList<AppNotification> items = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void addFromFcm({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    final n = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: data,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    items.insert(0, n);
    _save();
  }

  void markRead(String id) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(isRead: true);
    _save();
  }

  void clearAll() {
    items.clear();
    _save();
  }

  void _load() {
    final raw = _box.read(_key);
    if (raw == null) return;

    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      items.assignAll(list);
    } catch (_) {}
  }

  void _save() {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    _box.write(_key, raw);
  }
}
