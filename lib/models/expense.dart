import 'package:hive/hive.dart';
import 'split.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String payerId;

  @HiveField(4)
  List<Split> splits;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? category;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.splits,
    required this.date,
    this.category,
  });

  // Copy with method
  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? payerId,
    List<Split>? splits,
    DateTime? date,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      splits: splits ?? this.splits,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'payerId': payerId,
      'splits': splits.map((s) => s.toJson()).toList(),
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      payerId: json['payerId'] as String,
      splits: (json['splits'] as List)
          .map((s) => Split.fromJson(s as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
    );
  }

  @override
  String toString() =>
      'Expense(id: $id, description: $description, amount: $amount)';
}

