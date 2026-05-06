import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final onboardingDone = await storage.isOnboardingDone();

    if (!onboardingDone) {
      if (mounted) context.go('/onboarding');
      return;
    }

    final token = await storage.getToken();
    if (token != null) {
      await ref.read(authProvider.notifier).checkAuth();
      if (!mounted) return;
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go(user.isAdmin ? '/admin' : '/member');
        return;
      }
    }
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'KBMT',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Koperasi Simpan Pinjam',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
