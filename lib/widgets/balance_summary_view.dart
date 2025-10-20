import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../utils/currency_formatter.dart';
import 'empty_state.dart';

class BalanceSummaryView extends StatelessWidget {
  const BalanceSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final balances = groupProvider.getMemberBalances();

        if (balances.isEmpty) {
          return const EmptyState(
            icon: Icons.balance,
            title: 'No Balances',
            message: 'Add some expenses to see how balances are calculated.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: balances.length,
          itemBuilder: (context, index) {
            final memberBalance = balances[index];
            final member = memberBalance.member;
            final balance = memberBalance.balance;

            Color cardColor;
            Color textColor;
            String statusText;
            IconData icon;

            if (balance > 0.01) {
              // Member is owed money
              cardColor = Colors.green.shade50;
              textColor = Colors.green.shade700;
              statusText = 'gets back';
              icon = Icons.arrow_downward;
            } else if (balance < -0.01) {
              // Member owes money
              cardColor = Colors.red.shade50;
              textColor = Colors.red.shade700;
              statusText = 'owes';
              icon = Icons.arrow_upward;
            } else {
              // Settled up
              cardColor = Colors.grey.shade100;
              textColor = Colors.grey.shade700;
              statusText = 'settled up';
              icon = Icons.check_circle_outline;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      backgroundColor: Color(member.avatarColorValue ?? 0xFF6200EE),
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name and balance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(icon, size: 16, color: textColor),
                              const SizedBox(width: 4),
                              Text(
                                balance.abs() < 0.01
                                    ? statusText
                                    : '$statusText ${CurrencyFormatter.format(balance.abs())}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Balance amount (large)
                    if (balance.abs() >= 0.01)
                      Text(
                        CurrencyFormatter.format(balance.abs()),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

