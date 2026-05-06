import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_service.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  NotificationNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _ref.read(notificationServiceProvider).getNotifications();
      state = AsyncValue.data(items);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _ref.read(notificationServiceProvider).markAsRead(id);
      await load();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _ref.read(notificationServiceProvider).markAllAsRead();
      await load();
    } catch (_) {}
  }

  int get unreadCount {
    return state.whenOrNull(data: (items) => items.where((n) => !n.isRead).length) ?? 0;
  }
}
