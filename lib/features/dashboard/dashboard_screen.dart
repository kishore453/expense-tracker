import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../../shared/models/expense_model.dart';
import '../add_expense/add_expense_sheet.dart';
import '../transactions/widgets/expense_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final expenses = ref.watch(expenseListProvider);
    final recent = expenses.take(8).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _DashboardAppBar(userName: userName),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const _BalanceCard().animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                const SizedBox(height: 16),
                const _QuickStats().animate().fadeIn(duration: 500.ms, delay: 100.ms),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Recent Transactions',
                  onSeeAll: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                ).animate().fadeIn(delay: 200.ms),
                if (recent.isEmpty)
                  _EmptyState().animate().fadeIn(delay: 300.ms)
                else
                  ...List.generate(recent.length, (i) {
                    return ExpenseTile(expense: recent[i])
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 200 + i * 60))
                        .slideX(begin: 0.05);
                  }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddExpense(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
        elevation: 4,
      ).animate().scale(delay: 600.ms),
    );
  }

  void _openAddExpense(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sliver App Bar
// ---------------------------------------------------------------------------

class _DashboardAppBar extends ConsumerWidget {
  const _DashboardAppBar({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(isDarkModeProvider.notifier).toggle(),
            icon: Icon(
              ref.watch(isDarkModeProvider)
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          _NotificationBell(),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return '🌅 Good morning,';
    if (hour < 17) return '☀️ Good afternoon,';
    return '🌙 Good evening,';
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Balance Card
// ---------------------------------------------------------------------------

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final month = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  month,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balance.toCurrency(symbol),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceChip(
                  label: 'Income',
                  amount: totalIncome.toCurrency(symbol),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BalanceChip(
                  label: 'Expenses',
                  amount: totalExpenses.toCurrency(symbol),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                ),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Stats
// ---------------------------------------------------------------------------

class _QuickStats extends ConsumerWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thisMonth = ref.watch(thisMonthExpensesProvider);
    final monthExpenses = thisMonth
        .where((e) => e.type == ExpenseType.expense)
        .fold(0.0, (s, e) => s + e.amount);
    final symbol = ref.watch(currencySymbolProvider);
    final txCount = ref.watch(expenseListProvider).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'This Month',
              value: monthExpenses.toCompact(symbol),
              icon: Icons.calendar_month_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Transactions',
              value: txCount.toString(),
              icon: Icons.receipt_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Categories',
              value: ref.watch(categoryListProvider).length.toString(),
              icon: Icons.category_rounded,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first expense',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
