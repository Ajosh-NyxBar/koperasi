import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/admin/members')) return 1;
    if (loc.startsWith('/admin/products')) return 2;
    if (loc.startsWith('/admin/savings') || loc.startsWith('/admin/financings') || loc.startsWith('/admin/penalties')) return 3;
    if (loc.startsWith('/admin/reports')) return 4;
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
            case 0: context.go('/admin');
            case 1: context.go('/admin/members');
            case 2: context.go('/admin/products');
            case 3: context.go('/admin/financings');
            case 4: context.go('/admin/reports');
          }
        },
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Anggota'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: 'Keuangan'),
          NavigationDestination(icon: Icon(Icons.assessment_rounded), label: 'Laporan'),
        ],
      ),
    );
  }
}
