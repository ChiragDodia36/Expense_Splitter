import '../models/group.dart';
import '../models/member.dart';
import 'balance_service.dart';

/// Simple and clear service to calculate overall balances across all groups
class OverallBalanceServiceV2 {
  final BalanceService _balanceService = BalanceService();

  /// Calculate overall balances - much simpler approach
  List<PersonOverallBalance> calculateOverallBalances(List<Group> groups, String currentUserName) {
    final personBalanceMap = <String, PersonOverallBalance>{};

    // For each group, calculate balances
    for (var group in groups) {
      final groupBalances = _balanceService.calculateBalances(group);
      
      final currentUserMember = group.members.where((m) => m.name == currentUserName).firstOrNull;
      
      if (currentUserMember == null) {
        continue;
      }
      
      final currentUserBalance = groupBalances[currentUserMember.id] ?? 0;

      // For each other member in this group
      for (var member in group.members) {
        if (member.name == currentUserName) continue;
        
        final memberBalance = groupBalances[member.id] ?? 0;
        
        // Calculate the net amount between you and this person
        // The key insight: we need to calculate what you and this person owe each other
        // based on their individual balances in this group
        
        double netAmount = 0;
        
        // If you have positive balance (you're owed money) and they have negative balance (they owe money)
        // Then they owe you money
        if (currentUserBalance > 0 && memberBalance < 0) {
          // They owe you the amount of their debt
          netAmount = memberBalance.abs();
        }
        // If you have negative balance (you owe money) and they have positive balance (they're owed money)  
        // Then you owe them money
        else if (currentUserBalance < 0 && memberBalance > 0) {
          // You owe them the amount of your debt
          netAmount = -currentUserBalance.abs();
        }
        // If both have positive balances or both have negative balances,
        // they don't directly owe each other in this group
        
        // Only add if there's a meaningful amount
        if (netAmount.abs() > 0.01) {
          if (!personBalanceMap.containsKey(member.name)) {
            personBalanceMap[member.name] = PersonOverallBalance(
              name: member.name,
              totalBalance: 0,
              groups: [],
              member: member,
            );
          }
          
          personBalanceMap[member.name]!.totalBalance += netAmount;
          personBalanceMap[member.name]!.groups.add(GroupBalanceDetail(
            group: group,
            amount: netAmount,
          ));
        }
      }
    }

    // Convert to list and sort by absolute balance
    final result = personBalanceMap.values.toList();
    result.sort((a, b) => b.totalBalance.abs().compareTo(a.totalBalance.abs()));

    return result;
  }

  /// Get total amount you owe across all groups
  double getTotalYouOwe(List<Group> groups, String currentUserName) {
    final balances = calculateOverallBalances(groups, currentUserName);
    return balances
        .where((p) => p.totalBalance < 0)
        .fold(0.0, (sum, p) => sum + p.totalBalance.abs());
  }

  /// Get total amount owed to you across all groups
  double getTotalOwedToYou(List<Group> groups, String currentUserName) {
    final balances = calculateOverallBalances(groups, currentUserName);
    return balances
        .where((p) => p.totalBalance > 0)
        .fold(0.0, (sum, p) => sum + p.totalBalance);
  }
}

/// Overall balance for a person across all groups
class PersonOverallBalance {
  final String name;
  double totalBalance;
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
