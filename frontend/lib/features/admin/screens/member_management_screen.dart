import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../providers/member_provider.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  ConsumerState<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends ConsumerState<MemberManagementScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memberListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Anggota')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/members/create'),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari anggota...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () {
                        _searchCtrl.clear();
                        ref.read(memberListProvider.notifier).load(search: '');
                      })
                    : null,
              ),
              onSubmitted: (v) => ref.read(memberListProvider.notifier).load(search: v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(memberListProvider.notifier).load(),
              child: state.isLoading && state.members.isEmpty
                  ? const ShimmerList()
                  : state.members.isEmpty
                      ? const EmptyState(icon: Icons.people_outline, title: 'Tidak ada anggota')
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.members.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final m = state.members[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  backgroundImage: m.photoUrl != null ? NetworkImage(m.photoUrl!) : null,
                                  child: m.photoUrl == null ? Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)) : null,
                                ),
                                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.memberId, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                    if (m.savingBalance != null) Text('Saldo: ${m.savingBalance!.currency}', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.error))])),
                                  ],
                                  onSelected: (v) async {
                                    if (v == 'edit') context.push('/admin/members/${m.id}/edit');
                                    if (v == 'delete') {
                                      final ok = await ConfirmDialog.show(context, title: 'Hapus Anggota', message: 'Yakin hapus ${m.name}?', confirmLabel: 'Hapus', confirmColor: AppColors.error, icon: Icons.delete_forever);
                                      if (ok == true) {
                                        await ref.read(memberListProvider.notifier).delete(m.id);
                                        if (mounted) context.showSuccessSnack('Anggota dihapus');
                                      }
                                    }
                                  },
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
