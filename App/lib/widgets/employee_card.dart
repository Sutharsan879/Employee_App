import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/models/employee.dart';
import 'package:employee_app/screens/employee_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee});

  final Employee employee;
  static const _avatarRadius = 22.0;

  @override
  Widget build(BuildContext context) {
    final sinceText = DateFormat('MMM yyyy').format(employee.joiningDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 5),
      child: Material(
        color: employee.isFlagged ? AppColors.flagGreenBg : AppColors.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EmployeeDetailScreen(employee: employee),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: employee.isFlagged
                    ? AppColors.flagGreen.withValues(alpha: 0.25)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 72,
                  decoration: BoxDecoration(
                    color: employee.isFlagged
                        ? AppColors.flagGreen
                        : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.lg),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'employee_avatar_${employee.id}',
                          child: _Avatar(employee: employee),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      employee.name,
                                      style: AppText.titleMd.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (employee.isFlagged) ...[
                                    const SizedBox(width: 6),
                                    const _FlagBadge(),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                employee.designation,
                                style: AppText.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DepartmentChip(label: employee.department),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _StatusDot(isActive: employee.isActive),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Since $sinceText',
                                style: AppText.micro.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.flagGreen,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            '5+ Yrs',
            style: AppText.micro.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentChip extends StatelessWidget {
  const _DepartmentChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.micro.copyWith(
          color: AppColors.primary,
          fontSize: 10,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.flagGreenLight : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Active' : 'Off',
          style: AppText.micro.copyWith(
            fontSize: 10,
            color: isActive ? AppColors.flagGreen : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final color =
        employee.isFlagged ? AppColors.flagGreen : AppColors.primary;

    if (employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: EmployeeCard._avatarRadius,
        backgroundColor: color,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: employee.avatarUrl!,
            width: EmployeeCard._avatarRadius * 2,
            height: EmployeeCard._avatarRadius * 2,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                _Initials(employee: employee, color: color),
          ),
        ),
      );
    }
    return _Initials(employee: employee, color: color);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.employee, required this.color});
  final Employee employee;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: EmployeeCard._avatarRadius,
      backgroundColor: color,
      child: Text(
        employee.initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
