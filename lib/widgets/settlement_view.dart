import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/confirmation_dialog.dart';

class SettlementView extends StatelessWidget {
  const SettlementView({super.key});

  Future<void> _markAsPaid(
    BuildContext context,
    String fromMemberId,
    String toMemberId,
    double amount,
  ) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    if (group == null) return;

    final fromMember = group.getMemberById(fromMemberId);
    final toMember = group.getMemberById(toMemberId);

    if (fromMember == null || toMember == null) return;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Confirm Payment',
      message: '${fromMember.name} paid ${toMember.name} ${CurrencyFormatter.format(amount)}?',
      confirmText: 'Mark as Paid',
      isDangerous: false,
    );

    if (!context.mounted) return;

    if (confirmed) {
      await groupProvider.recordSettlement(
        groupId: group.id,
        fromMemberId: fromMemberId,
        toMemberId: toMemberId,
        amount: amount,
      );

      if (context.mounted) {
        ConfirmationDialog.showSuccess(
          context,
          message: 'Settlement recorded!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final settlements = groupProvider.getSettlements();
        final isSettled = groupProvider.isGroupSettled();
        final settlementHistory = groupProvider.getSettlementHistory();

        if (isSettled || settlements.isEmpty) {
          return _buildSettledState(context, settlementHistory, groupProvider);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Suggested Settlements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${settlements.length} transaction${settlements.length == 1 ? '' : 's'} needed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settlements List
            ...settlements.map((settlement) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // From member
                          Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(
                                    settlement.from.avatarColorValue ?? 0xFFEF5350,
                                  ),
                                  child: Text(
                                    settlement.from.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  settlement.from.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Arrow and amount
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    CurrencyFormatter.format(settlement.amount),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // To member
                          Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(
                                    settlement.to.avatarColorValue ?? 0xFF66BB6A,
                                  ),
                                  child: Text(
                                    settlement.to.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  settlement.to.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mark as Paid button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _markAsPaid(
                            context,
                            settlement.from.id,
                            settlement.to.id,
                            settlement.amount,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Mark as Paid'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Settlement History Section
            if (settlementHistory.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSettlementHistory(context, settlementHistory, groupProvider),
            ],

            const SizedBox(height: 16),

            // Info card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap "Mark as Paid" when a settlement is completed.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettledState(BuildContext context, List settlementHistory, GroupProvider groupProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'All Settled Up!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everyone has paid their share',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        if (settlementHistory.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSettlementHistory(context, settlementHistory, groupProvider),
        ],
      ],
    );
  }

  Widget _buildSettlementHistory(
    BuildContext context,
    List settlementHistory,
    GroupProvider groupProvider,
  ) {
    final group = groupProvider.selectedGroup;
    if (group == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Settlement History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${settlementHistory.length} payment${settlementHistory.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...settlementHistory.reversed.map((settlement) {
          final fromMember = group.getMemberById(settlement.fromMemberId);
          final toMember = group.getMemberById(settlement.toMemberId);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.check, color: Colors.green.shade700),
              ),
              title: Text(
                '${fromMember?.name ?? 'Unknown'} paid ${toMember?.name ?? 'Unknown'}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.formatDateRelative(settlement.paidAt)),
                  if (settlement.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      settlement.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(settlement.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
              ),
              onLongPress: () => _deleteSettlement(context, settlement.id),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _deleteSettlement(BuildContext context, String settlementId) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Settlement',
      message: 'Are you sure you want to remove this settlement record?',
      confirmText: 'Delete',
    );

    if (!context.mounted) return;

    if (confirmed) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final group = groupProvider.selectedGroup;
      if (group != null) {
        await groupProvider.deleteSettlementPayment(group.id, settlementId);
        if (context.mounted) {
          ConfirmationDialog.showSuccess(
            context,
            message: 'Settlement deleted',
          );
        }
      }
    }
  }
}
