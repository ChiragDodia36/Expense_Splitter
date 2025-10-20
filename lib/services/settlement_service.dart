import '../models/group.dart';
import '../models/member.dart';
import 'balance_service.dart';

class SettlementService {
  final BalanceService _balanceService = BalanceService();

  /// Calculate optimized settlements to minimize number of transactions
  /// Uses a greedy algorithm to match highest creditor with highest debtor
  List<Settlement> calculateSettlements(Group group) {
    final balances = _balanceService.calculateBalances(group);
    final settlements = <Settlement>[];

    // Separate creditors (positive balance) and debtors (negative balance)
    final creditors = <BalanceEntry>[];
    final debtors = <BalanceEntry>[];

    for (var entry in balances.entries) {
      final member = group.getMemberById(entry.key);
      if (member != null) {
        if (entry.value > 0.01) {
          // Small threshold to handle floating point errors
          creditors.add(BalanceEntry(member, entry.value));
        } else if (entry.value < -0.01) {
          debtors.add(BalanceEntry(member, entry.value.abs()));
        }
      }
    }

    // Sort creditors (descending) and debtors (descending)
    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    // Match creditors with debtors using greedy algorithm
    int i = 0, j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      final settlementAmount = creditor.amount < debtor.amount
          ? creditor.amount
          : debtor.amount;

      settlements.add(Settlement(
        from: debtor.member,
        to: creditor.member,
        amount: settlementAmount,
      ));

      creditor.amount -= settlementAmount;
      debtor.amount -= settlementAmount;

      if (creditor.amount < 0.01) i++;
      if (debtor.amount < 0.01) j++;
    }

    return settlements;
  }

  /// Check if group is fully settled (all balances are zero)
  bool isGroupSettled(Group group) {
    final balances = _balanceService.calculateBalances(group);
    return balances.values.every((balance) => balance.abs() < 0.01);
  }

  /// Get number of transactions needed to settle
  int getTransactionCount(Group group) {
    return calculateSettlements(group).length;
  }

  /// Calculate settlements between two specific members
  Settlement? getSettlementBetween(
    Group group,
    String fromMemberId,
    String toMemberId,
  ) {
    final settlements = calculateSettlements(group);
    return settlements.firstWhere(
      (s) => s.from.id == fromMemberId && s.to.id == toMemberId,
      orElse: () => settlements.firstWhere(
        (s) => s.from.id == toMemberId && s.to.id == fromMemberId,
        orElse: () => throw Exception('No settlement found'),
      ),
    );
  }
}

/// Represents a settlement transaction
class Settlement {
  final Member from;
  final Member to;
  final double amount;

  Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  String toString() => '${from.name} pays ${to.name} \$${amount.toStringAsFixed(2)}';
}

/// Helper class for balance calculations
class BalanceEntry {
  final Member member;
  double amount;

  BalanceEntry(this.member, this.amount);
}

