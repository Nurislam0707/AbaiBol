import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../providers/notification_providers.dart';
import '../../domain/models/notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBody(
        slivers: [
          const GlassHeader(
            title: 'Хабарландырулар',
            canPop: true,
          ),
          if (notifications.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Сізде әзірге хабарлама жоқ', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0 && notifications.any((n) => !n.isRead)) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Жаңа хабарламалар',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
                              child: const Text('Барлығын оқылды деп белгілеу'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final adjustedIndex = notifications.any((n) => !n.isRead) ? index - 1 : index;
                    if (adjustedIndex < 0 || adjustedIndex >= notifications.length) return null;
                    
                    final notification = notifications[adjustedIndex];
                    return NotificationCard(notification: notification);
                  },
                  childCount: notifications.length + (notifications.any((n) => !n.isRead) ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationCard extends ConsumerWidget {
  const NotificationCard({super.key, required this.notification});

  final NotificationItem notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
        ),
        onDismissed: (_) => ref.read(notificationsProvider.notifier).deleteNotification(notification.id),
        child: GestureDetector(
          onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notification.id),
          child: SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.isRead 
                        ? Colors.grey.withValues(alpha: 0.1) 
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notification.isRead 
                          ? Colors.grey.withValues(alpha: 0.1) 
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    notification.isRead 
                        ? Icons.notifications_none_rounded 
                        : Icons.notifications_active_rounded,
                    color: notification.isRead ? Colors.grey : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                color: notification.isRead ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) : null,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: notification.isRead 
                              ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) 
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин бұрын';
    if (diff.inHours < 24) return '${diff.inHours} сағ бұрын';
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}
