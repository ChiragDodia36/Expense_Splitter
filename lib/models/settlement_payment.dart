import 'package:hive/hive.dart';

part 'settlement_payment.g.dart';

@HiveType(typeId: 4)
class SettlementPayment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromMemberId;

  @HiveField(2)
  final String toMemberId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime paidAt;

  @HiveField(5)
  String? note;

  SettlementPayment({
    required this.id,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.paidAt,
    this.note,
  });

  // Copy with method
  SettlementPayment copyWith({
    String? id,
    String? fromMemberId,
    String? toMemberId,
    double? amount,
    DateTime? paidAt,
    String? note,
  }) {
    return SettlementPayment(
      id: id ?? this.id,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amount': amount,
      'paidAt': paidAt.toIso8601String(),
      'note': note,
    };
  }

  factory SettlementPayment.fromJson(Map<String, dynamic> json) {
    return SettlementPayment(
      id: json['id'] as String,
      fromMemberId: json['fromMemberId'] as String,
      toMemberId: json['toMemberId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: DateTime.parse(json['paidAt'] as String),
      note: json['note'] as String?,
    );
  }

  @override
  String toString() =>
      'SettlementPayment(from: $fromMemberId, to: $toMemberId, amount: $amount)';
}

