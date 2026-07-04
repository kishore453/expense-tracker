import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../add_expense/add_expense_sheet.dart';
import 'widgets/expense_tile.dart';

// Filter state
final _filterProvider = StateProvider<String>((ref) => 'All');
final _searchProvider = StateProvider<String>((ref) => '');

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(_filterProvider);
    final search = ref.watch(_searchProvider);
    final allExpenses = ref.watch(expenseListProvider);

    final filtered = allExpenses.where((e) {
      final matchFilter = filter == 'All' ||
          (filter == 'Income' && e.type == ExpenseType.income) ||
          (filter == 'Expense' && e.type == ExpenseType.expense);
      final matchSearch =
          search.isEmpty || e.title.toLowerCase().contains(search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () => _openAddExpense(context),
            icon: const Icon(Icons.add_circle_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(_searchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_searchProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Expense', 'Income'].map((f) {
                final selected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(_filterProvider.notifier).state = f,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: filtered.isEmpty
                ? _EmptyTransactions(filter: filter)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      return ExpenseTile(expense: filtered[i])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: i * 40))
                          .slideX(begin: 0.05);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseSheet(),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'All' ? 'No transactions yet' : 'No $filter transactions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction using the + button',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
