import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/screens/employee_form_screen.dart';
import 'package:employee_app/providers/employee_provider.dart';
import 'package:employee_app/widgets/decorative_widgets.dart';
import 'package:employee_app/widgets/employee_card.dart';
import 'package:employee_app/widgets/error_widget.dart';
import 'package:employee_app/widgets/search_bar_widget.dart';
import 'package:employee_app/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().initialize();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 180) {
      context.read<EmployeeProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const EmployeeFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text('Add'),
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.primary,
            child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(provider)),
              if (provider.isOffline)
                SliverToBoxAdapter(child: _buildOfflineBanner(provider)),
              if (_isSearchExpanded)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: SearchBarWidget(
                      controller: _searchController,
                      onChanged: provider.search,
                      onClear: () {
                        _searchController.clear();
                        provider.search('');
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: _buildFilterRow(provider)),
              _buildBodySliver(provider),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(EmployeeProvider provider) {
    final hasData = provider.total > 0 || provider.employees.isNotEmpty;

    return DecorativeBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Employees',
                          style: AppText.titleLg.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Team directory & tenure',
                          style: AppText.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                        if (!_isSearchExpanded) {
                          _searchController.clear();
                          provider.search('');
                        }
                      });
                    },
                    icon: Icon(
                      _isSearchExpanded ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      minimumSize: const Size(40, 40),
                    ),
                  ),
                ],
              ),
              if (hasData) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    StatCard(
                      icon: Icons.groups_outlined,
                      label: 'Total',
                      value: '${provider.total}',
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Active',
                      value: '${provider.activeCount}',
                      iconColor: AppColors.flagGreen,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatCard(
                      icon: Icons.military_tech_outlined,
                      label: '5+ Yrs',
                      value: '${provider.flaggedCount}',
                      iconColor: AppColors.accent,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(EmployeeProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No network — pull to refresh when back online',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: provider.refresh,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(EmployeeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              selected: provider.filter == EmployeeListFilter.all,
              onSelected: () => provider.setFilter(EmployeeListFilter.all),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Active',
              selected: provider.filter == EmployeeListFilter.active,
              onSelected: () => provider.setFilter(EmployeeListFilter.active),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: '5+ Years',
              selected: provider.filter == EmployeeListFilter.flagged,
              onSelected: () => provider.setFilter(EmployeeListFilter.flagged),
              isGreen: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySliver(EmployeeProvider provider) {
    if (provider.isLoading && provider.employees.isEmpty) {
      return const EmployeeShimmerSliver();
    }

    if (provider.error != null && provider.employees.isEmpty) {
      return SliverFillRemaining(
        child: AppErrorWidget(
          message: provider.error!,
          onRetry: provider.refresh,
        ),
      );
    }

    final employees = provider.employees;

    if (employees.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          message: provider.searchQuery.isNotEmpty
              ? 'Try a different search or filter.'
              : 'No employees to display.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= employees.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return EmployeeCard(employee: employees[index]);
          },
          childCount: employees.length + (provider.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.isGreen = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    final color = isGreen ? AppColors.flagGreen : AppColors.primary;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppText.caption.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
