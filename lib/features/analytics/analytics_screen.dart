import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../../shared/models/expense_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const _SpendingBarChart()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 20),
          const _CategoryPieChart()
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 20),
          const _TopCategories()
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar Chart: Monthly Spending
// ---------------------------------------------------------------------------

class _SpendingBarChart extends ConsumerWidget {
  const _SpendingBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final entries = monthlyTotals.entries.toList();
    final maxVal = entries.fold<double>(
        0, (m, e) => e.value > m ? e.value : m);

    return _AnalyticsCard(
      title: 'Monthly Spending',
      subtitle: 'Last 6 months',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxVal == 0 ? 1000 : maxVal * 1.3,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal == 0 ? 200 : maxVal * 0.3,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (val, _) => Text(
                    val.toCompact(symbol),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= entries.length) return const SizedBox();
                    final parts = entries[idx].key.split('-');
                    final month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MMM').format(month),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(entries.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryVariant],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal == 0 ? 1000 : maxVal * 1.3,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.07),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pie Chart: Category Breakdown
// ---------------------------------------------------------------------------

class _CategoryPieChart extends ConsumerWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catTotals = ref.watch(categoryTotalsProvider);
    final categories = ref.watch(categoryListProvider);
    final symbol = ref.watch(currencySymbolProvider);

    if (catTotals.isEmpty) {
      return _AnalyticsCard(
        title: 'Category Breakdown',
        subtitle: 'Expense distribution',
        child: const SizedBox(
          height: 180,
          child: Center(child: Text('No expense data yet')),
        ),
      );
    }

    final total = catTotals.values.fold(0.0, (s, v) => s + v);
    final sections = catTotals.entries.map((entry) {
      final cat = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => categories.first,
      );
      final color = AppColors.categoryColors[cat.colorIndex % AppColors.categoryColors.length];
      final pct = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 54,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        borderSide: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      );
    }).toList();

    return _AnalyticsCard(
      title: 'Category Breakdown',
      subtitle: 'Total: ${total.toCurrency(symbol)}',
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: catTotals.entries.take(5).map((entry) {
                final cat = categories.firstWhere(
                  (c) => c.id == entry.key,
                  orElse: () => categories.first,
                );
                final color = AppColors.categoryColors[cat.colorIndex % AppColors.categoryColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Categories Table
// ---------------------------------------------------------------------------

class _TopCategories extends ConsumerWidget {
  const _TopCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catTotals = ref.watch(categoryTotalsProvider);
    final categories = ref.watch(categoryListProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final total = catTotals.values.fold(0.0, (s, v) => s + v);

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return _AnalyticsCard(
      title: 'Top Categories',
      subtitle: 'Highest spending',
      child: Column(
        children: top.map((entry) {
          final cat = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => categories.first,
          );
          final color = AppColors.categoryColors[cat.colorIndex % AppColors.categoryColors.length];
          final pct = total > 0 ? entry.value / total : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(cat.icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      entry.value.toCurrency(symbol),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.danger,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Wrapper
// ---------------------------------------------------------------------------

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
