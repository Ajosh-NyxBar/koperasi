import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (image == null) return;

    final success = await ref.read(authProvider.notifier).updateProfile({
      'photo': await MultipartFile.fromFile(image.path, filename: image.name),
    });
    if (success && mounted) context.showSuccessSnack('Foto berhasil diperbarui');
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar',
      message: 'Yakin ingin keluar dari aplikasi?',
      confirmLabel: 'Keluar',
      confirmColor: AppColors.error,
      icon: Icons.logout_rounded,
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  void _showChangePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubah Password', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            AppTextField(label: 'Password Saat Ini', controller: currentCtrl, obscureText: true, prefixIcon: Icons.lock_outline),
            const SizedBox(height: 12),
            AppTextField(label: 'Password Baru', controller: newCtrl, obscureText: true, prefixIcon: Icons.lock_outline),
            const SizedBox(height: 12),
            AppTextField(label: 'Konfirmasi', controller: confirmCtrl, obscureText: true, prefixIcon: Icons.lock_outline),
            const SizedBox(height: 20),
            AppButton(
              label: 'Simpan',
              onPressed: () async {
                final success = await ref.read(authProvider.notifier).updateProfile({
                  'current_password': currentCtrl.text,
                  'password': newCtrl.text,
                  'password_confirmation': confirmCtrl.text,
                });
                if (success && mounted) {
                  Navigator.pop(ctx);
                  context.showSuccessSnack('Password berhasil diubah');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                    child: user?.photoUrl == null ? Icon(Icons.person, size: 48, color: AppColors.primary) : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text(user?.email ?? '', style: TextStyle(color: AppColors.onSurfaceVariant)),
            if (user?.member != null) Text('ID: ${user!.member!.memberId}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 24),

            // Menu items
            _MenuItem(icon: Icons.person_outline, label: 'Edit Profil', onTap: () {
              // Could navigate to edit profile screen
            }),
            _MenuItem(icon: Icons.lock_outline, label: 'Ubah Password', onTap: _showChangePassword),
            _MenuItem(
              icon: themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              label: 'Mode Tema',
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.phone_android, size: 16)),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
                ],
                selected: {themeMode},
                onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v.first),
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Keluar',
              onPressed: _logout,
              isOutlined: true,
              color: AppColors.error,
              icon: Icons.logout_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _MenuItem({required this.icon, required this.label, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
