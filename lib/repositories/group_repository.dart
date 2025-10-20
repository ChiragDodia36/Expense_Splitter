import 'package:hive/hive.dart';
import '../models/group.dart';
import '../models/expense.dart';
import '../models/member.dart';
import '../models/settlement_payment.dart';
import '../services/hive_service.dart';

class GroupRepository {
  final Box<Group> _groupBox = HiveService.getGroupsBox();

  // ==================== GROUP OPERATIONS ====================

  /// Get all groups
  List<Group> getAllGroups() {
    return _groupBox.values.toList();
  }

  /// Get a group by ID
  Group? getGroupById(String id) {
    return _groupBox.values.firstWhere(
      (group) => group.id == id,
      orElse: () => throw Exception('Group not found'),
    );
  }

  /// Create a new group
  Future<void> createGroup(Group group) async {
    await _groupBox.put(group.id, group);
  }

  /// Update an existing group
  Future<void> updateGroup(Group group) async {
    group.updatedAt = DateTime.now();
    await _groupBox.put(group.id, group);
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    await _groupBox.delete(groupId);
  }

  /// Check if a group exists
  bool groupExists(String groupId) {
    return _groupBox.containsKey(groupId);
  }

  // ==================== MEMBER OPERATIONS ====================

  /// Add a member to a group
  Future<void> addMember(String groupId, Member member) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.members.add(member);
      await updateGroup(group);
    }
  }

  /// Update a member in a group
  Future<void> updateMember(String groupId, Member updatedMember) async {
    final group = getGroupById(groupId);
    if (group != null) {
      final index = group.members.indexWhere((m) => m.id == updatedMember.id);
      if (index != -1) {
        group.members[index] = updatedMember;
        await updateGroup(group);
      }
    }
  }

  /// Remove a member from a group
  Future<void> removeMember(String groupId, String memberId) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.members.removeWhere((m) => m.id == memberId);
      // Also remove this member from all expense splits
      for (var expense in group.expenses) {
        expense.splits.removeWhere((split) => split.memberId == memberId);
      }
      await updateGroup(group);
    }
  }

  // ==================== EXPENSE OPERATIONS ====================

  /// Add an expense to a group
  Future<void> addExpense(String groupId, Expense expense) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.expenses.add(expense);
      await updateGroup(group);
    }
  }

  /// Update an expense in a group
  Future<void> updateExpense(String groupId, Expense updatedExpense) async {
    final group = getGroupById(groupId);
    if (group != null) {
      final index = group.expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        group.expenses[index] = updatedExpense;
        await updateGroup(group);
      }
    }
  }

  /// Delete an expense from a group
  Future<void> deleteExpense(String groupId, String expenseId) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.expenses.removeWhere((e) => e.id == expenseId);
      await updateGroup(group);
    }
  }

  /// Get all expenses in a group
  List<Expense> getGroupExpenses(String groupId) {
    final group = getGroupById(groupId);
    return group?.expenses ?? [];
  }

  // ==================== SETTLEMENT OPERATIONS ====================

  /// Add a settlement payment to a group
  Future<void> addSettlementPayment(String groupId, SettlementPayment settlement) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.settlements.add(settlement);
      await updateGroup(group);
    }
  }

  /// Get all settlements in a group
  List<SettlementPayment> getGroupSettlements(String groupId) {
    final group = getGroupById(groupId);
    return group?.settlements ?? [];
  }

  /// Delete a settlement payment
  Future<void> deleteSettlementPayment(String groupId, String settlementId) async {
    final group = getGroupById(groupId);
    if (group != null) {
      group.settlements.removeWhere((s) => s.id == settlementId);
      await updateGroup(group);
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get total number of groups
  int getGroupCount() {
    return _groupBox.length;
  }

  /// Clear all groups (use with caution!)
  Future<void> clearAllGroups() async {
    await _groupBox.clear();
  }

  /// Listen to changes in groups
  Stream<BoxEvent> watchGroups() {
    return _groupBox.watch();
  }
}

