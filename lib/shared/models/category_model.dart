import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

/// Expense category stored in Hive
@HiveType(typeId: 1)
class ExpenseCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  int colorIndex;

  @HiveField(4)
  bool isCustom;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorIndex,
    this.isCustom = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons', matchTextDirection: false);

  ExpenseCategory copyWith({
    String? name,
    int? iconCodePoint,
    int? colorIndex,
    bool? isCustom,
  }) {
    return ExpenseCategory(
      id: id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorIndex: colorIndex ?? this.colorIndex,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
