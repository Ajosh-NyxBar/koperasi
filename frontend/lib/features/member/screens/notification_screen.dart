import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
            child: const Text('Tandai Semua'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).load(),
        child: state.when(
          loading: () => const ShimmerList(),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) return const EmptyState(icon: Icons.notifications_off_outlined, title: 'Tidak ada notifikasi');
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final n = items[i];
                return InkWell(
                  onTap: () {
                    if (!n.isRead) ref.read(notificationProvider.notifier).markAsRead(n.id);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead ? Theme.of(context).cardTheme.color : AppColors.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: n.isRead ? AppColors.outline : AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            n.isRead ? Icons.notifications_outlined : Icons.notifications_active_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(n.body, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(n.createdAt.relative, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
