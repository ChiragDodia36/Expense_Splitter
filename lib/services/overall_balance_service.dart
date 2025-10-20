import '../models/group.dart';
import '../models/member.dart';
import 'balance_service.dart';

/// Service to calculate overall balances across all groups
class OverallBalanceService {
  final BalanceService _balanceService = BalanceService();

  /// Calculate total balances across all groups
  /// Returns a map of person name -> net balance
  Map<String, double> calculateOverallBalances(List<Group> groups, String currentUserName) {
    final overallBalances = <String, double>{};

    for (var group in groups) {
      final groupBalances = _balanceService.calculateBalances(group);
      
      for (var entry in groupBalances.entries) {
        final member = group.getMemberById(entry.key);
        if (member != null && member.name != currentUserName) {
          overallBalances[member.name] = 
              (overallBalances[member.name] ?? 0) + entry.value;
        }
      }
    }

    return overallBalances;
  }

  /// Get current user's net balance across all groups
  double getCurrentUserBalance(List<Group> groups, String currentUserName) {
    double totalBalance = 0;

    for (var group in groups) {
      final groupBalances = _balanceService.calculateBalances(group);
      
      for (var entry in groupBalances.entries) {
        final member = group.getMemberById(entry.key);
        if (member != null && member.name == currentUserName) {
          totalBalance += entry.value;
          break;
        }
      }
    }

    return totalBalance;
  }

  /// Get detailed breakdown by person across all groups
  List<PersonOverallBalance> getPersonBalances(List<Group> groups, String currentUserName) {
    final personBalanceMap = <String, PersonBalanceData>{};

    // Collect balances from all groups
    for (var group in groups) {
      final groupBalances = _balanceService.calculateBalances(group);
      final currentUserMember = group.members.where((m) => m.name == currentUserName).firstOrNull;
      
      if (currentUserMember == null) continue;
      
      final currentUserBalance = groupBalances[currentUserMember.id] ?? 0;

      for (var entry in groupBalances.entries) {
        final member = group.getMemberById(entry.key);
        if (member != null && member.name != currentUserName) {
          if (!personBalanceMap.containsKey(member.name)) {
            personBalanceMap[member.name] = PersonBalanceData(
              name: member.name,
              totalBalance: 0,
              groups: [],
              member: member,
            );
          }

          // Simple approach: calculate what you and this person owe each other
          final memberBalance = entry.value;
          
          // In this group:
          // - If your balance is positive, you are owed money
          // - If your balance is negative, you owe money
          // - If their balance is positive, they are owed money  
          // - If their balance is negative, they owe money
          
          // Calculate net amount between you and this person in this group
          double netAmount = 0;
          
          if (currentUserBalance > 0 && memberBalance < 0) {
            // You are owed money (positive balance) and they owe money (negative balance)
            // So they owe you the amount of their debt
            netAmount = memberBalance.abs(); // Positive = they owe you
          } else if (currentUserBalance < 0 && memberBalance > 0) {
            // You owe money (negative balance) and they are owed money (positive balance)
            // So you owe them the amount of your debt
            netAmount = -currentUserBalance.abs(); // Negative = you owe them
          }
          // If both positive or both negative, they don't owe each other directly

          if (netAmount.abs() > 0.01) {
            personBalanceMap[member.name]!.totalBalance += netAmount;
            personBalanceMap[member.name]!.groups.add(GroupBalanceDetail(
              group: group,
              amount: netAmount,
            ));
          }
        }
      }
    }

    // Convert to list and sort by absolute balance
    final result = personBalanceMap.values
        .where((p) => p.totalBalance.abs() > 0.01)
        .map((data) => PersonOverallBalance(
              name: data.name,
              totalBalance: data.totalBalance,
              groups: data.groups,
              member: data.member,
            ))
        .toList();

    result.sort((a, b) => b.totalBalance.abs().compareTo(a.totalBalance.abs()));

    return result;
  }

  /// Get simplified settlements across all groups
  List<OverallSettlement> getOverallSettlements(List<Group> groups, String currentUserName) {
    final personBalances = getPersonBalances(groups, currentUserName);
    final settlements = <OverallSettlement>[];

    // Separate people you owe from people who owe you
    final peopleYouOwe = personBalances.where((p) => p.totalBalance < -0.01).toList();
    final peopleWhoOweYou = personBalances.where((p) => p.totalBalance > 0.01).toList();

    // Sort by amount
    peopleYouOwe.sort((a, b) => a.totalBalance.compareTo(b.totalBalance));
    peopleWhoOweYou.sort((a, b) => b.totalBalance.compareTo(a.totalBalance));

    int i = 0, j = 0;
    while (i < peopleYouOwe.length && j < peopleWhoOweYou.length) {
      final debtor = peopleYouOwe[i];
      final creditor = peopleWhoOweYou[j];

      final debtAmount = debtor.totalBalance.abs();
      final creditAmount = creditor.totalBalance;

      final settlementAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      settlements.add(OverallSettlement(
        fromPerson: currentUserName,
        toPerson: debtor.totalBalance < 0 ? debtor.name : creditor.name,
        amount: settlementAmount,
        isPayment: debtor.totalBalance < 0, // true if you're paying them
      ));

      // Update remaining amounts
      peopleYouOwe[i] = debtor.copyWith(
        totalBalance: debtor.totalBalance + settlementAmount,
      );
      peopleWhoOweYou[j] = creditor.copyWith(
        totalBalance: creditor.totalBalance - settlementAmount,
      );

      if (peopleYouOwe[i].totalBalance.abs() < 0.01) i++;
      if (peopleWhoOweYou[j].totalBalance.abs() < 0.01) j++;
    }

    return settlements;
  }

  /// Get total amount you owe across all groups
  double getTotalYouOwe(List<Group> groups, String currentUserName) {
    final personBalances = getPersonBalances(groups, currentUserName);
    return personBalances
        .where((p) => p.totalBalance < 0)
        .fold(0.0, (sum, p) => sum + p.totalBalance.abs());
  }

  /// Get total amount owed to you across all groups
  double getTotalOwedToYou(List<Group> groups, String currentUserName) {
    final personBalances = getPersonBalances(groups, currentUserName);
    return personBalances
        .where((p) => p.totalBalance > 0)
        .fold(0.0, (sum, p) => sum + p.totalBalance);
  }
}

/// Data class for person balance across groups
class PersonBalanceData {
  final String name;
  double totalBalance;
  final List<GroupBalanceDetail> groups;
  final Member member;

  PersonBalanceData({
    required this.name,
    required this.totalBalance,
    required this.groups,
    required this.member,
  });
}

/// Overall balance for a person across all groups
class PersonOverallBalance {
  final String name;
  final double totalBalance;
  final List<GroupBalanceDetail> groups;
  final Member member;

  PersonOverallBalance({
    required this.name,
    required this.totalBalance,
    required this.groups,
    required this.member,
  });

  bool get youOwe => totalBalance < 0;
  bool get owesYou => totalBalance > 0;
  bool get settled => totalBalance.abs() < 0.01;

  PersonOverallBalance copyWith({
    String? name,
    double? totalBalance,
    List<GroupBalanceDetail>? groups,
    Member? member,
  }) {
    return PersonOverallBalance(
      name: name ?? this.name,
      totalBalance: totalBalance ?? this.totalBalance,
      groups: groups ?? this.groups,
      member: member ?? this.member,
    );
  }
}

/// Balance detail for a specific group
class GroupBalanceDetail {
  final Group group;
  final double amount;

  GroupBalanceDetail({
    required this.group,
    required this.amount,
  });
}

/// Overall settlement suggestion
class OverallSettlement {
  final String fromPerson;
  final String toPerson;
  final double amount;
  final bool isPayment; // true if fromPerson pays toPerson

  OverallSettlement({
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
    required this.isPayment,
  });
}

