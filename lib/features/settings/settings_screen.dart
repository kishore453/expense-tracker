import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final currency = ref.watch(currencyProvider);
    final userName = ref.watch(userNameProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final totalIncome = ref.watch(totalIncomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          _ProfileCard(name: userName, symbol: symbol, expense: totalExpenses, income: totalIncome)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.05),
          const SizedBox(height: 20),

          // Appearance
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.primaryVariant,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: (_) => ref.read(isDarkModeProvider.notifier).toggle(),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // Preferences
          _SettingsSection(
            title: 'Preferences',
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: AppColors.accent,
                title: 'Display Name',
                subtitle: userName,
                onTap: () => _editName(context, ref, userName),
              ),
              _SettingsTile(
                icon: Icons.currency_exchange_rounded,
                iconColor: AppColors.warning,
                title: 'Currency',
                subtitle: '${currency['name']} (${currency['symbol']})',
                onTap: () => _pickCurrency(context, ref),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),

          // Data
          _SettingsSection(
            title: 'Data',
            children: [
              _SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: AppColors.danger,
                title: 'Clear All Transactions',
                subtitle: 'This action cannot be undone',
                onTap: () => _clearData(context, ref),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // About
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: AppConstants.appName,
                subtitle: 'Version ${AppConstants.appVersion}',
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(userNameProvider.notifier).setName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickCurrency(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CurrencyPicker(),
    );
  }

  void _clearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data'),
        content: const Text(
          'All transactions will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final expenses = ref.read(expenseListProvider);
              for (final e in expenses) {
                ref.read(expenseListProvider.notifier).delete(e.id);
              }
              Navigator.pop(ctx);
              context.showSnack('All transactions cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Card
// ---------------------------------------------------------------------------

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({
    required this.name,
    required this.symbol,
    required this.expense,
    required this.income,
  });
  final String name;
  final String symbol;
  final double expense;
  final double income;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Net: ${(income - expense).toCurrency(symbol)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
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

// ---------------------------------------------------------------------------
// Settings Section
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Tile
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Currency Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _CurrencyPicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currencyProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Select Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: AppConstants.currencies.length,
              itemBuilder: (ctx, i) {
                final c = AppConstants.currencies[i];
                final selected = c['code'] == current['code'];
                return ListTile(
                  title: Text(c['name']!),
                  subtitle: Text('${c['code']} · ${c['symbol']}'),
                  trailing: selected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(currencyProvider.notifier).setCurrency(
                          Map<String, String>.from(c),
                        );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
