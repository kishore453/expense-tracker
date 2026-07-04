import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/expense_model.dart';

// ---------------------------------------------------------------------------
// Expense Repository
// ---------------------------------------------------------------------------

class ExpenseRepository {
  Box<Expense> get _box => Hive.box<Expense>(AppConstants.expenseBoxName);
  final _uuid = const Uuid();

  List<Expense> getAll() => _box.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  void add(Expense expense) => _box.put(expense.id, expense);

  void update(Expense expense) => _box.put(expense.id, expense);

  void delete(String id) => _box.delete(id);

  String generateId() => _uuid.v4();
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expenseListProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpenseNotifier(repo);
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final ExpenseRepository _repo;

  ExpenseNotifier(this._repo) : super(_repo.getAll());

  void add(Expense expense) {
    _repo.add(expense);
    state = _repo.getAll();
  }

  void update(Expense expense) {
    _repo.update(expense);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  void refresh() {
    state = _repo.getAll();
  }
}

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses
      .where((e) => e.type == ExpenseType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);
});

final totalIncomeProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses
      .where((e) => e.type == ExpenseType.income)
      .fold(0.0, (sum, e) => sum + e.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpensesProvider);
});

/// Expenses filtered by current month
final thisMonthExpensesProvider = Provider<List<Expense>>((ref) {
  final now = DateTime.now();
  final expenses = ref.watch(expenseListProvider);
  return expenses.where((e) =>
      e.date.year == now.year && e.date.month == now.month).toList();
});

/// Monthly spending totals for bar chart (last 6 months)
final monthlyTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();
  final result = <String, double>{};

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    result[key] = expenses
        .where((e) =>
            e.type == ExpenseType.expense &&
            e.date.year == month.year &&
            e.date.month == month.month)
        .fold(0.0, (s, e) => s + e.amount);
  }
  return result;
});

/// Category-wise totals for pie chart
final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final result = <String, double>{};
  for (final e in expenses.where((e) => e.type == ExpenseType.expense)) {
    result[e.categoryId] = (result[e.categoryId] ?? 0) + e.amount;
  }
  return result;
});
