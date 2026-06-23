import 'package:employee_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Sliver-friendly shimmer placeholders (no nested ListView).
class EmployeeShimmerSliver extends StatelessWidget {
  const EmployeeShimmerSliver({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => const _ShimmerCard(),
        childCount: count,
      ),
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 5,
        ),
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
