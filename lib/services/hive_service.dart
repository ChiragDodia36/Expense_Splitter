import 'package:hive_flutter/hive_flutter.dart';
import '../models/member.dart';
import '../models/split.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/settlement_payment.dart';

class HiveService {
  static const String groupsBoxName = 'groups';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register type adapters
    Hive.registerAdapter(MemberAdapter());
    Hive.registerAdapter(SplitAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(SettlementPaymentAdapter());

    // Open boxes
    await Hive.openBox<Group>(groupsBoxName);
  }

  /// Get the groups box
  static Box<Group> getGroupsBox() {
    return Hive.box<Group>(groupsBoxName);
  }

  /// Close all boxes (call on app dispose if needed)
  static Future<void> close() async {
    await Hive.close();
  }
}

