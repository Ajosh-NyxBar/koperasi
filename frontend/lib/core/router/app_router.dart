import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/member/screens/member_shell.dart';
import '../../features/member/screens/product_catalog_screen.dart';
import '../../features/member/screens/member_dashboard_screen.dart';
import '../../features/member/screens/saving_screen.dart';
import '../../features/member/screens/financing_screen.dart';
import '../../features/member/screens/financing_detail_screen.dart';
import '../../features/member/screens/financing_simulation_screen.dart';
import '../../features/member/screens/financing_apply_screen.dart';
import '../../features/member/screens/social_fund_screen.dart';
import '../../features/member/screens/profile_screen.dart';
import '../../features/member/screens/notification_screen.dart';
import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/member_management_screen.dart';
import '../../features/admin/screens/member_form_screen.dart';
import '../../features/admin/screens/product_management_screen.dart';
import '../../features/admin/screens/saving_management_screen.dart';
import '../../features/admin/screens/financing_management_screen.dart';
import '../../features/admin/screens/penalty_management_screen.dart';
import '../../features/admin/screens/report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) => ResetPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // Member Shell
      ShellRoute(
        builder: (_, __, child) => MemberShell(child: child),
        routes: [
          GoRoute(path: '/member', builder: (_, __) => const MemberDashboardScreen()),
          GoRoute(path: '/member/products', builder: (_, __) => const ProductCatalogScreen()),
          GoRoute(path: '/member/savings', builder: (_, __) => const SavingScreen()),
          GoRoute(path: '/member/financings', builder: (_, __) => const FinancingScreen()),
          GoRoute(path: '/member/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/member/financings/:id',
        builder: (_, state) => FinancingDetailScreen(
          financingId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/member/financings-simulate', builder: (_, __) => const FinancingSimulationScreen()),
      GoRoute(path: '/member/financings-apply', builder: (_, __) => const FinancingApplyScreen()),
      GoRoute(path: '/member/social-fund', builder: (_, __) => const SocialFundScreen()),
      GoRoute(path: '/member/notifications', builder: (_, __) => const NotificationScreen()),

      // Admin Shell
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/members', builder: (_, __) => const MemberManagementScreen()),
          GoRoute(path: '/admin/products', builder: (_, __) => const ProductManagementScreen()),
          GoRoute(path: '/admin/savings', builder: (_, __) => const AdminSavingManagementScreen()),
          GoRoute(path: '/admin/financings', builder: (_, __) => const FinancingManagementScreen()),
          GoRoute(path: '/admin/penalties', builder: (_, __) => const PenaltyManagementScreen()),
          GoRoute(path: '/admin/reports', builder: (_, __) => const ReportScreen()),
        ],
      ),
      GoRoute(
        path: '/admin/members/create',
        builder: (_, __) => const MemberFormScreen(),
      ),
      GoRoute(
        path: '/admin/members/:id/edit',
        builder: (_, state) => MemberFormScreen(
          memberId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});
