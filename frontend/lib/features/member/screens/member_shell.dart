import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class MemberShell extends StatelessWidget {
  final Widget child;
  const MemberShell({super.key, required this.child});

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/member/products')) return 1;
    if (loc.startsWith('/member/savings')) return 2;
    if (loc.startsWith('/member/financings')) return 3;
    if (loc.startsWith('/member/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _index(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/member');
            case 1: context.go('/member/products');
            case 2: context.go('/member/savings');
            case 3: context.go('/member/financings');
            case 4: context.go('/member/profile');
          }
        },
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.savings_rounded), label: 'Tabungan'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), label: 'Pembiayaan'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
