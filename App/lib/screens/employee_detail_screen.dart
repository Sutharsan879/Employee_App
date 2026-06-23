import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/models/employee.dart';
import 'package:employee_app/providers/employee_provider.dart';
import 'package:employee_app/screens/employee_form_screen.dart';
import 'package:employee_app/services/employee_service.dart';
import 'package:employee_app/widgets/decorative_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key, required this.employee});

  final Employee employee;

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Employee _employee;
  bool _loading = true;
  bool _deleting = false;

  Future<void> _openEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(employee: _employee),
      ),
    );
    if (updated == true && mounted) {
      await _loadDetail();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete employee?'),
        content: Text(
          'Remove ${_employee.name} from the directory? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await context.read<EmployeeProvider>().deleteEmployee(_employee.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on EmployeeServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final fresh = await EmployeeService().fetchEmployee(_employee.id);
      if (mounted) {
        setState(() {
          _employee = fresh;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final joined = DateFormat('MMMM d, yyyy').format(_employee.joiningDate);
    final tenureText = '${_employee.yearsOfService} years';
    final gradient = _employee.isFlagged
        ? AppColors.flaggedGradient
        : AppColors.headerGradient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: _employee.isFlagged
                      ? AppColors.flagGreen
                      : AppColors.primaryDark,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 22),
                      onPressed: _loading || _deleting ? null : _openEdit,
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: _deleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_outline,
                              color: Colors.white, size: 22),
                      onPressed: _loading || _deleting ? null : _confirmDelete,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: DecorativeBackground(
                      gradient: gradient,
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Hero(
                              tag: 'employee_avatar_${_employee.id}',
                              child: _Avatar(employee: _employee),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Text(
                                _employee.name,
                                textAlign: TextAlign.center,
                                style: AppText.titleLg.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _BadgeRow(employee: _employee),
                        const SizedBox(height: AppSpacing.md),
                        _Card(
                          title: 'Work Details',
                          child: Column(
                            children: [
                              _Row(
                                icon: Icons.work_outline,
                                label: 'Designation',
                                value: _employee.designation,
                              ),
                              _Row(
                                icon: Icons.apartment_outlined,
                                label: 'Department',
                                value: _employee.department,
                              ),
                              _Row(
                                icon: Icons.event_outlined,
                                label: 'Joining Date',
                                value: joined,
                              ),
                              _Row(
                                icon: Icons.schedule_outlined,
                                label: 'Years of Service',
                                value: tenureText,
                                highlight: _employee.isFlagged,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _Card(
                          title: 'Contact',
                          child: Column(
                            children: [
                              _CopyRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _employee.email,
                                onTap: () => _copy(context, _employee.email),
                              ),
                              if (_employee.phone != null &&
                                  _employee.phone!.isNotEmpty)
                                _CopyRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: _employee.phone!,
                                  onTap: () =>
                                      _copy(context, _employee.phone!),
                                  isLast: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loading || _deleting ? null : _openEdit,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _loading || _deleting ? null : _confirmDelete,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: Text(_deleting ? 'Deleting...' : 'Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final bg = employee.isFlagged ? AppColors.flagGreen : Colors.white;
    const r = 40.0;

    if (employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: r,
        backgroundColor: bg,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: employee.avatarUrl!,
            width: r * 2,
            height: r * 2,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _Initials(employee: employee, r: r),
          ),
        ),
      );
    }
    return _Initials(employee: employee, r: r);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.employee, required this.r});
  final Employee employee;
  final double r;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: r,
      backgroundColor: employee.isFlagged ? AppColors.flagGreen : Colors.white,
      child: Text(
        employee.initials,
        style: TextStyle(
          fontSize: r * 0.45,
          fontWeight: FontWeight.w700,
          color: employee.isFlagged ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (employee.isFlagged) ...[
          _pill('5+ Year Employee', AppColors.flagGreen, Icons.military_tech, Colors.white),
          const SizedBox(width: AppSpacing.sm),
        ],
        _pill(
          employee.isActive ? 'Active' : 'Inactive',
          employee.isActive ? AppColors.flagGreenBg : Colors.grey.shade100,
          employee.isActive ? Icons.check_circle : Icons.cancel_outlined,
          employee.isActive ? AppColors.flagGreen : AppColors.textSecondary,
          textColor: employee.isActive ? AppColors.flagGreen : AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _pill(String text, Color bg, IconData icon, Color iconColor, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(text, style: AppText.caption.copyWith(color: textColor ?? iconColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SectionHeader(title: title), child],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = highlight ? AppColors.flagGreen : AppColors.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.micro.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppText.titleMd.copyWith(
                    fontSize: 15,
                    color: highlight ? AppColors.flagGreen : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppText.micro.copyWith(color: AppColors.textSecondary)),
                      Text(value, style: AppText.caption.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.copy, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
