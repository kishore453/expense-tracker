import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/category_model.dart';

class CategoryRepository {
  Box<ExpenseCategory> get _box =>
      Hive.box<ExpenseCategory>(AppConstants.categoryBoxName);
  final _uuid = const Uuid();

  List<ExpenseCategory> getAll() => _box.values.toList();

  void add(ExpenseCategory cat) => _box.put(cat.id, cat);

  void update(ExpenseCategory cat) => _box.put(cat.id, cat);

  void delete(String id) => _box.delete(id);

  bool get isEmpty => _box.isEmpty;

  String generateId() => _uuid.v4();
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoryListProvider =
    StateNotifierProvider<CategoryNotifier, List<ExpenseCategory>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repo);
});

class CategoryNotifier extends StateNotifier<List<ExpenseCategory>> {
  final CategoryRepository _repo;

  CategoryNotifier(CategoryRepository repo)
      : _repo = repo,
        super(repo.getAll()) {
    _seedDefaults();
  }

  void _seedDefaults() {
    if (_repo.isEmpty) {
      for (final data in AppConstants.defaultCategories) {
        final cat = ExpenseCategory(
          id: _repo.generateId(),
          name: data['name'] as String,
          iconCodePoint: data['icon'] as int,
          colorIndex: data['colorIndex'] as int,
        );
        _repo.add(cat);
      }
      state = _repo.getAll();
    }
  }

  void add(ExpenseCategory cat) {
    _repo.add(cat);
    state = _repo.getAll();
  }

  void update(ExpenseCategory cat) {
    _repo.update(cat);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  ExpenseCategory? findById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final categoryByIdProvider =
    Provider.family<ExpenseCategory?, String>((ref, id) {
  final cats = ref.watch(categoryListProvider);
  try {
    return cats.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
