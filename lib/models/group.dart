import 'package:hive/hive.dart';
import 'member.dart';
import 'expense.dart';
import 'settlement_payment.dart';

part 'group.g.dart';

@HiveType(typeId: 3)
class Group extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Member> members;

  @HiveField(3)
  List<Expense> expenses;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  List<SettlementPayment> settlements;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.expenses,
    required this.createdAt,
    this.updatedAt,
    List<SettlementPayment>? settlements,
  }) : settlements = settlements ?? [];

  // Copy with method
  Group copyWith({
    String? id,
    String? name,
    List<Member>? members,
    List<Expense>? expenses,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SettlementPayment>? settlements,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settlements: settlements ?? this.settlements,
    );
  }

  // Calculate total expenses in this group
  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get member by ID
  Member? getMemberById(String memberId) {
    try {
      return members.firstWhere((m) => m.id == memberId);
    } catch (e) {
      return null;
    }
  }

  // Check if member exists
  bool hasMember(String memberId) {
    return members.any((m) => m.id == memberId);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'settlements': settlements.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      members: (json['members'] as List)
          .map((m) => Member.fromJson(m as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      settlements: json['settlements'] != null
          ? (json['settlements'] as List)
              .map((s) => SettlementPayment.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() => 'Group(id: $id, name: $name, members: ${members.length})';
}

