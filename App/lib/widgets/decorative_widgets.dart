import 'package:employee_app/config/app_config.dart';
import 'package:flutter/material.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.headerGradient,
  });

  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        return Stack(
          clipBehavior: Clip.none,
          fit: hasBoundedHeight ? StackFit.expand : StackFit.loose,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
            const Positioned(
              top: -50,
              right: -40,
              child: _Blob(size: 160, opacity: 0.08),
            ),
            const Positioned(
              top: 30,
              left: -60,
              child: _Blob(size: 120, opacity: 0.06),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppText.titleMd.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppText.micro.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppText.titleMd.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
