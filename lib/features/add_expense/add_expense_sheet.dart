import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../shared/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key, this.existing});
  final Expense? existing;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  ExpenseType _type = ExpenseType.expense;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEditing) {
      final e = widget.existing!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _notesController.text = e.notes ?? '';
      _selectedCategoryId = e.categoryId;
      _selectedDate = e.date;
      _isRecurring = e.isRecurring;
      _type = e.type;
      _tabController.index = e.type == ExpenseType.expense ? 0 : 1;
    }

    _tabController.addListener(() {
      setState(() {
        _type = _tabController.index == 0 ? ExpenseType.expense : ExpenseType.income;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final isExpense = _type == ExpenseType.expense;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      _isEditing ? 'Edit Transaction' : 'New Transaction',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: isExpense ? AppColors.danger : AppColors.success,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: '  Expense  '),
                      Tab(text: '  Income  '),
                    ],
                  ),
                ),
              ),
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      // Amount field (large)
                      _AmountField(
                        controller: _amountController,
                        symbol: symbol,
                        isExpense: isExpense,
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 16),
                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'e.g. Grocery shopping',
                        icon: Icons.title_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      // Category selector
                      _CategorySelector(
                        categories: categories,
                        selectedId: _selectedCategoryId,
                        onSelected: (id) =>
                            setState(() => _selectedCategoryId = id),
                        isExpense: isExpense,
                      ),
                      const SizedBox(height: 12),
                      // Date picker
                      _DatePickerTile(
                        date: _selectedDate,
                        onPick: (d) => setState(() => _selectedDate = d),
                      ),
                      const SizedBox(height: 12),
                      // Notes
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes (optional)',
                        hint: 'Add a note...',
                        icon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      // Recurring toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.repeat_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recurring',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge),
                                  Text('Mark as recurring transaction',
                                      style:
                                          Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _isRecurring,
                              onChanged: (v) =>
                                  setState(() => _isRecurring = v),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isExpense ? AppColors.danger : AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _save,
                          child: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      context.showSnack('Please select a category', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      context.showSnack('Please enter a valid amount', isError: true);
      return;
    }

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        type: _type,
        isRecurring: _isRecurring,
      );
      ref.read(expenseListProvider.notifier).update(updated);
      context.showSnack('Transaction updated!');
    } else {
      final expense = Expense(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        type: _type,
        isRecurring: _isRecurring,
      );
      ref.read(expenseListProvider.notifier).add(expense);
      context.showSnack('Transaction saved!');
    }

    Navigator.pop(context);
  }
}

// ---------------------------------------------------------------------------
// Amount Field
// ---------------------------------------------------------------------------

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.symbol,
    required this.isExpense,
  });
  final TextEditingController controller;
  final String symbol;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isExpense
            ? LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.05),
                  AppColors.danger.withOpacity(0.02)
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.05),
                  AppColors.success.withOpacity(0.02)
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isExpense ? AppColors.danger : AppColors.success).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isExpense ? AppColors.danger : AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: isExpense ? AppColors.danger : AppColors.success,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: (isExpense ? AppColors.danger : AppColors.success)
                      .withOpacity(0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount required';
                final d = double.tryParse(v);
                if (d == null || d <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Selector
// ---------------------------------------------------------------------------

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.isExpense,
  });
  final List categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Category',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final selected = cat.id == selectedId;
              final color = AppColors.categoryColors[
                  cat.colorIndex % AppColors.categoryColors.length];
              return GestureDetector(
                onTap: () => onSelected(cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.15) : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: selected ? color : Theme.of(context).colorScheme.outline, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        cat.name.split(' ').first,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected ? color : null,
                              fontWeight: selected ? FontWeight.w700 : null,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date Picker Tile
// ---------------------------------------------------------------------------

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.date, required this.onPick});
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
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
