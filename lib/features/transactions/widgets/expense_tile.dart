import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../add_expense/add_expense_sheet.dart';

class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({super.key, required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(expense.categoryId));
    final symbol = ref.watch(currencySymbolProvider);
    final isExpense = expense.type == ExpenseType.expense;

    final catColor = category != null
        ? AppColors.categoryColors[category.colorIndex % AppColors.categoryColors.length]
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => _editExpense(context),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => _deleteExpense(context, ref),
              backgroundColor: AppColors.danger.withOpacity(0.1),
              foregroundColor: AppColors.danger,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category?.icon ?? Icons.more_horiz_rounded,
                  color: catColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Title & category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          category?.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Text(' · ', style: TextStyle(color: Colors.grey)),
                        Text(
                          expense.date.toShortDate(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}${expense.amount.toCurrency(symbol)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isExpense ? AppColors.danger : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (expense.isRecurring)
                    Row(
                      children: [
                        Icon(Icons.repeat_rounded, size: 10, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 2),
                        Text(
                          'Recurring',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(existing: expense),
    );
  }

  void _deleteExpense(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
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
              ref.read(expenseListProvider.notifier).delete(expense.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
