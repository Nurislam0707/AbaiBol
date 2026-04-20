import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/notification_item.dart';

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    // Initial mock notifications
    return [
      NotificationItem(
        id: '1',
        title: 'Пікір білдіру мүмкіндігі',
        message: 'Қожан Ақеркеге пікір білдіру уақытыңыз ашылды. Өз ойыңызды бөлісіңіз!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Жүйелік хабарлама',
        message: 'Профиль мәліметтері сәтті жаңартылды. Қолданбаның барлық мүмкіндіктерін пайдалана аласыз.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Жаңа жетістік!',
        message: 'Сіз "Белсенді қолданушы" жетістігін аштыңыз. Құттықтаймыз!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final item in state) item.copyWith(isRead: true),
    ];
  }

  void deleteNotification(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
      NotificationsNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
