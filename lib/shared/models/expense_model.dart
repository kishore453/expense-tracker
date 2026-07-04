import 'package:hive/hive.dart';

part 'expense_model.g.dart';

/// Expense type enum
@HiveType(typeId: 3)
enum ExpenseType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

/// Core expense/income model stored in Hive
@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  ExpenseType type;

  @HiveField(8)
  bool isRecurring;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
    this.imagePath,
    this.type = ExpenseType.expense,
    this.isRecurring = false,
  });

  Expense copyWith({
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? notes,
    String? imagePath,
    ExpenseType? type,
    bool? isRecurring,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount)';
}
