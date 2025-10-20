import '../models/group.dart';
import '../models/member.dart';

/// Correct overall balance calculation
/// The key insight: we need to look at expenses to see who paid for what
/// and who participated in what, then calculate net amounts
class OverallBalanceServiceV3 {

  /// Calculate overall balances - correct approach
  List<PersonOverallBalance> calculateOverallBalances(List<Group> groups, String currentUserName) {
    final personBalanceMap = <String, PersonOverallBalance>{};

    for (var group in groups) {
      final currentUserMember = group.members.where((m) => m.name == currentUserName).firstOrNull;
      
      if (currentUserMember == null) continue;

      // For each expense in this group
      for (var expense in group.expenses) {
        final currentUserSplit = expense.splits.where((s) => s.memberId == currentUserMember.id).firstOrNull;
        
        // Only process if current user participated in this expense
        if (currentUserSplit == null) continue;

        // Check if current user paid for this expense
        final didCurrentUserPay = expense.payerId == currentUserMember.id;

        // For each other person who participated in this expense
        for (var split in expense.splits) {
          if (split.memberId == currentUserMember.id) continue; // Skip current user
          
          final otherMember = group.getMemberById(split.memberId);
          if (otherMember == null) continue;

          if (!personBalanceMap.containsKey(otherMember.name)) {
            personBalanceMap[otherMember.name] = PersonOverallBalance(
              name: otherMember.name,
              totalBalance: 0,
              groups: [],
              member: otherMember,
            );
          }

          double netAmount = 0;

          if (didCurrentUserPay) {
            // Current user paid, other person owes their share
            netAmount = split.amount; // Positive = they owe you
          } else {
            // Current user didn't pay, so we need to see who did pay
            final didOtherPersonPay = expense.payerId == split.memberId;
            if (didOtherPersonPay) {
              // Other person paid, so current user owes their share
              netAmount = -currentUserSplit.amount; // Negative = you owe them
            }
            // If neither current user nor other person paid, no direct debt between them
          }

          // Always add the net amount, even if it's 0 (it will be filtered out later)
          personBalanceMap[otherMember.name]!.totalBalance += netAmount;
          if (netAmount.abs() > 0.01) {
            personBalanceMap[otherMember.name]!.groups.add(GroupBalanceDetail(
              group: group,
              amount: netAmount,
            ));
          }
        }
      }
    }

    // Convert to list, filter out settled balances, and sort by absolute balance
    final result = personBalanceMap.values
        .where((p) => p.totalBalance.abs() > 0.01) // Only include meaningful balances
        .toList();
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
