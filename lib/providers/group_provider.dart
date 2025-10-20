import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/split.dart';
import '../models/settlement_payment.dart';
import '../repositories/group_repository.dart';
import '../services/balance_service.dart';
import '../services/settlement_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository = GroupRepository();
  final BalanceService _balanceService = BalanceService();
  final SettlementService _settlementService = SettlementService();
  final Uuid _uuid = const Uuid();

  List<Group> _groups = [];
  Group? _selectedGroup;

  List<Group> get groups => _groups;
  Group? get selectedGroup => _selectedGroup;

  GroupProvider() {
    loadGroups();
  }

  // ==================== GROUP OPERATIONS ====================

  /// Load all groups from repository
  void loadGroups() {
    _groups = _repository.getAllGroups();
    notifyListeners();
  }

  /// Select a group for viewing/editing
  void selectGroup(String groupId) {
    _selectedGroup = _repository.getGroupById(groupId);
    notifyListeners();
  }

  /// Clear selected group
  void clearSelection() {
    _selectedGroup = null;
    notifyListeners();
  }

  /// Create a new group
  Future<Group> createGroup({
    required String name,
    required List<String> memberNames,
  }) async {
    final group = Group(
      id: _uuid.v4(),
      name: name,
      members: memberNames
          .map((name) => Member(
                id: _uuid.v4(),
                name: name,
                avatarColorValue: _generateRandomColor(),
              ))
          .toList(),
      expenses: [],
      createdAt: DateTime.now(),
    );

    await _repository.createGroup(group);
    loadGroups();
    return group;
  }

  /// Update group name
  Future<void> updateGroupName(String groupId, String newName) async {
    final group = _repository.getGroupById(groupId);
    if (group != null) {
      final updatedGroup = group.copyWith(name: newName);
      await _repository.updateGroup(updatedGroup);
      loadGroups();
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = updatedGroup;
        notifyListeners();
      }
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    await _repository.deleteGroup(groupId);
    if (_selectedGroup?.id == groupId) {
      _selectedGroup = null;
    }
    loadGroups();
  }

  // ==================== MEMBER OPERATIONS ====================

  /// Add a member to a group
  Future<void> addMember(String groupId, String memberName) async {
    final member = Member(
      id: _uuid.v4(),
      name: memberName,
      avatarColorValue: _generateRandomColor(),
    );
    await _repository.addMember(groupId, member);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  /// Update member name
  Future<void> updateMemberName(
    String groupId,
    String memberId,
    String newName,
  ) async {
    final group = _repository.getGroupById(groupId);
    if (group != null) {
      final member = group.getMemberById(memberId);
      if (member != null) {
        final updatedMember = member.copyWith(name: newName);
        await _repository.updateMember(groupId, updatedMember);
        loadGroups();
        if (_selectedGroup?.id == groupId) {
          selectGroup(groupId);
        }
      }
    }
  }

  /// Remove a member from a group
  Future<void> removeMember(String groupId, String memberId) async {
    await _repository.removeMember(groupId, memberId);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  // ==================== EXPENSE OPERATIONS ====================

  /// Add an expense with equal split
  Future<void> addExpenseEqualSplit({
    required String groupId,
    required String description,
    required double amount,
    required String payerId,
    required List<String> participantIds,
    String? category,
  }) async {
    final splitAmount = amount / participantIds.length;
    final splits = participantIds
        .map((id) => Split(memberId: id, amount: splitAmount))
        .toList();

    final expense = Expense(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      payerId: payerId,
      splits: splits,
      date: DateTime.now(),
      category: category,
    );

    await _repository.addExpense(groupId, expense);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  /// Add an expense with custom split
  Future<void> addExpenseCustomSplit({
    required String groupId,
    required String description,
    required double amount,
    required String payerId,
    required List<Split> splits,
    String? category,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      payerId: payerId,
      splits: splits,
      date: DateTime.now(),
      category: category,
    );

    await _repository.addExpense(groupId, expense);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  /// Update an expense
  Future<void> updateExpense(String groupId, Expense expense) async {
    await _repository.updateExpense(groupId, expense);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String groupId, String expenseId) async {
    await _repository.deleteExpense(groupId, expenseId);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  // ==================== BALANCE & SETTLEMENT ====================

  /// Get member balances for selected group
  List<MemberBalance> getMemberBalances() {
    if (_selectedGroup == null) return [];
    return _balanceService.getMemberBalances(_selectedGroup!);
  }

  /// Get settlement suggestions for selected group
  List<Settlement> getSettlements() {
    if (_selectedGroup == null) return [];
    return _settlementService.calculateSettlements(_selectedGroup!);
  }

  /// Check if selected group is settled
  bool isGroupSettled() {
    if (_selectedGroup == null) return true;
    return _settlementService.isGroupSettled(_selectedGroup!);
  }

  // ==================== SETTLEMENT PAYMENT OPERATIONS ====================

  /// Record a settlement payment
  Future<void> recordSettlement({
    required String groupId,
    required String fromMemberId,
    required String toMemberId,
    required double amount,
    String? note,
  }) async {
    final settlement = SettlementPayment(
      id: _uuid.v4(),
      fromMemberId: fromMemberId,
      toMemberId: toMemberId,
      amount: amount,
      paidAt: DateTime.now(),
      note: note,
    );

    await _repository.addSettlementPayment(groupId, settlement);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  /// Get settlement history for selected group
  List<SettlementPayment> getSettlementHistory() {
    if (_selectedGroup == null) return [];
    return _selectedGroup!.settlements;
  }

  /// Delete a settlement payment
  Future<void> deleteSettlementPayment(String groupId, String settlementId) async {
    await _repository.deleteSettlementPayment(groupId, settlementId);
    loadGroups();
    if (_selectedGroup?.id == groupId) {
      selectGroup(groupId);
    }
  }

  // ==================== HELPER METHODS ====================

  /// Generate a random color value for member avatar
  int _generateRandomColor() {
    final colors = [
      0xFFEF5350, // Red
      0xFFEC407A, // Pink
      0xFFAB47BC, // Purple
      0xFF7E57C2, // Deep Purple
      0xFF5C6BC0, // Indigo
      0xFF42A5F5, // Blue
      0xFF29B6F6, // Light Blue
      0xFF26C6DA, // Cyan
      0xFF26A69A, // Teal
      0xFF66BB6A, // Green
      0xFF9CCC65, // Light Green
      0xFFD4E157, // Lime
      0xFFFFEE58, // Yellow
      0xFFFFCA28, // Amber
      0xFFFF7043, // Deep Orange
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch ~/ 1000) % colors.length];
  }

  /// Get total expenses for a group
  double getTotalExpenses(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    return group.totalExpenses;
  }
}

