import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../models/expense.dart';
import '../utils/currency_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/balance_summary_view.dart';
import '../widgets/settlement_view.dart';
import '../widgets/confirmation_dialog.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../services/pdf_service.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteGroup(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    if (group == null) return;

    final confirmed = await ConfirmationDialog.confirmDeleteGroup(
      context,
      group.name,
    );

    if (!context.mounted) return;

    if (confirmed) {
      await groupProvider.deleteGroup(group.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ConfirmationDialog.showSuccess(
          context,
          message: 'Group deleted successfully',
        );
      }
    }
  }

  Future<void> _exportPDF(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    if (group == null) return;

    try {
      final pdfService = PdfService();
      await pdfService.generateAndSharePdf(context, group);
    } catch (e) {
      if (context.mounted) {
        ConfirmationDialog.showErrorSnackBar(
          context,
          message: 'Error generating PDF: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.selectedGroup;

        if (group == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Group')),
            body: const Center(child: Text('Group not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _exportPDF(context),
                tooltip: 'Export PDF',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Group'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteGroup(context);
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Expenses', icon: Icon(Icons.receipt_long)),
                Tab(text: 'Balances', icon: Icon(Icons.balance)),
                Tab(text: 'Settle Up', icon: Icon(Icons.swap_horiz)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExpensesTab(group),
              const BalanceSummaryView(),
              const SettlementView(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(group) {
    if (group.expenses.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Expenses',
        message: 'Add your first expense to start tracking!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.expenses.length,
      itemBuilder: (context, index) {
        final expense = group.expenses[index];
        final payer = group.getMemberById(expense.payerId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                CurrencyFormatter.formatCompact(expense.amount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              expense.description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Paid by ${payer?.name ?? 'Unknown'}'),
                Text(
                  CurrencyFormatter.formatDateRelative(expense.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(expense.amount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${expense.splits.length} people',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editExpense(context, expense);
                    } else if (value == 'delete') {
                      _deleteExpense(context, expense.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _editExpense(context, expense),
          ),
        );
      },
    );
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }


  Future<void> _deleteExpense(BuildContext context, String expenseId) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    if (group == null) return;

    final expense = group.expenses.firstWhere((e) => e.id == expenseId);
    
    final confirmed = await ConfirmationDialog.confirmDeleteExpense(
      context,
      expense.description,
    );

    if (!context.mounted) return;

    if (confirmed) {
      await groupProvider.deleteExpense(group.id, expenseId);
      if (context.mounted) {
        ConfirmationDialog.showSuccess(
          context,
          message: 'Expense deleted',
        );
      }
    }
  }
}

