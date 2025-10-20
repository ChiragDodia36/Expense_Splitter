import 'package:hive/hive.dart';

part 'split.g.dart';

@HiveType(typeId: 1)
class Split extends HiveObject {
  @HiveField(0)
  final String memberId;

  @HiveField(1)
  double amount;

  Split({
    required this.memberId,
    required this.amount,
  });

  // Copy with method
  Split copyWith({
    String? memberId,
    double? amount,
  }) {
    return Split(
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'amount': amount,
    };
  }

  factory Split.fromJson(Map<String, dynamic> json) {
    return Split(
      memberId: json['memberId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'Split(memberId: $memberId, amount: $amount)';
}

