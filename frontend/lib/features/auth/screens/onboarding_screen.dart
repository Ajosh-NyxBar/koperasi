import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.savings_rounded,
      title: 'Simpanan Mudah',
      desc: 'Kelola tabungan wajib, pokok, dan sukarela Anda dalam satu aplikasi.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'Pembiayaan Transparan',
      desc: 'Ajukan pembiayaan dengan simulasi cicilan yang jelas dan transparan.',
      color: AppColors.secondary,
    ),
    _OnboardingPage(
      icon: Icons.volunteer_activism_rounded,
      title: 'Dana Sosial',
      desc: 'Berkontribusi dan ajukan bantuan dari dana sosial koperasi.',
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.outline,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: _page == _pages.length - 1 ? 'Mulai' : 'Selanjutnya',
                    onPressed: () {
                      if (_page == _pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(secureStorageProvider).setOnboardingDone();
    if (mounted) context.go('/login');
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
