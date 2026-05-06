import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
      highlightColor: isDark ? AppColors.darkOutline : Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(height: 18, width: 150),
          const SizedBox(height: 10),
          const ShimmerLoading(height: 14, width: 250),
          const SizedBox(height: 8),
          const ShimmerLoading(height: 14, width: 200),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade100),
        ],
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
