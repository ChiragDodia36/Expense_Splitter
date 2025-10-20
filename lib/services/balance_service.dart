import '../models/group.dart';
import '../models/member.dart';
import '../models/expense.dart';

class BalanceService {
  Map<String, double> calculateBalances(Group group) {
    final balances = <String, double>{};

    // Initialize balances for all members
    for (var member in group.members) {
      balances[member.id] = 0.0;
    }

    // Calculate for each expense
    for (var expense in group.expenses) {
      // Add to payer's balance (they paid)
      balances[expense.payerId] =
          (balances[expense.payerId] ?? 0) + expense.amount;

      // Subtract from participants' balances (they owe)
      for (var split in expense.splits) {
        balances[split.memberId] =
            (balances[split.memberId] ?? 0) - split.amount;
      }
    }

    // Adjust balances for settlement payments
    for (var settlement in group.settlements) {
      // When someone pays, their balance goes down (they have less owed to them or owe less)
      balances[settlement.fromMemberId] =
          (balances[settlement.fromMemberId] ?? 0) + settlement.amount;

      // When someone receives, their balance goes up (they are owed less or owe more)
      balances[settlement.toMemberId] =
          (balances[settlement.toMemberId] ?? 0) - settlement.amount;
    }

    return balances;
  }

  /// Get balance details with member information
  List<MemberBalance> getMemberBalances(Group group) {
    final balances = calculateBalances(group);
    final memberBalances = <MemberBalance>[];

    for (var entry in balances.entries) {
      final member = group.getMemberById(entry.key);
      if (member != null) {
        memberBalances.add(MemberBalance(member: member, balance: entry.value));
      }
    }

    // Sort by balance (highest to lowest)
    memberBalances.sort((a, b) => b.balance.compareTo(a.balance));

    return memberBalances;
  }

  /// Calculate total amount paid by each member
  Map<String, double> calculateTotalPaid(Group group) {
    final totalPaid = <String, double>{};

    for (var member in group.members) {
      totalPaid[member.id] = 0.0;
    }

    for (var expense in group.expenses) {
      totalPaid[expense.payerId] =
          (totalPaid[expense.payerId] ?? 0) + expense.amount;
    }

    return totalPaid;
  }

  /// Calculate total share for each member
  Map<String, double> calculateTotalShare(Group group) {
    final totalShare = <String, double>{};

    for (var member in group.members) {
      totalShare[member.id] = 0.0;
    }

    for (var expense in group.expenses) {
      for (var split in expense.splits) {
        totalShare[split.memberId] =
            (totalShare[split.memberId] ?? 0) + split.amount;
      }
    }

    return totalShare;
  }

  /// Get expenses where a member was the payer
  List<Expense> getExpensesPaidBy(Group group, String memberId) {
    return group.expenses.where((e) => e.payerId == memberId).toList();
  }

  /// Get expenses where a member participated
  List<Expense> getExpensesWithMember(Group group, String memberId) {
    return group.expenses
        .where((e) => e.splits.any((split) => split.memberId == memberId))
        .toList();
  }
}

/// Model for member balance with member information
class MemberBalance {
  final Member member;
  final double balance;

  MemberBalance({required this.member, required this.balance});

  bool get isOwed => balance > 0;
  bool get owes => balance < 0;
  bool get isSettled => balance == 0;

  double get absoluteBalance => balance.abs();
}
