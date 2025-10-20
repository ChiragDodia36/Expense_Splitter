import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../services/overall_balance_service_v3.dart';
import '../utils/currency_formatter.dart';

class OverallBalanceScreen extends StatefulWidget {
  const OverallBalanceScreen({super.key});

  @override
  State<OverallBalanceScreen> createState() => _OverallBalanceScreenState();
}

class _OverallBalanceScreenState extends State<OverallBalanceScreen> {
  final TextEditingController _userNameController = TextEditingController(text: 'Chirag');
  final OverallBalanceServiceV3 _overallBalanceService = OverallBalanceServiceV3();

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Balance'),
        elevation: 0,
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          final groups = groupProvider.groups;
          
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Groups Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create groups to see overall balances',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final currentUserName = _userNameController.text.trim();
          final personBalances = _overallBalanceService.calculateOverallBalances(groups, currentUserName);
          final totalYouOwe = _overallBalanceService.getTotalYouOwe(groups, currentUserName);
          final totalOwedToYou = _overallBalanceService.getTotalOwedToYou(groups, currentUserName);
          final netBalance = totalOwedToYou - totalYouOwe;
          
          // Get all unique member names across all groups for suggestions
          final allMemberNames = groups
              .expand((group) => group.members)
              .map((member) => member.name)
              .toSet()
              .toList()
              ..sort();

          return Column(
            children: [
              // User name input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'Enter your name as it appears in groups',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => setState(() {}),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                    ),
                    if (allMemberNames.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Available names in your groups:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8.0,
                        children: allMemberNames.map((name) {
                          final isSelected = _userNameController.text.trim() == name;
                          return FilterChip(
                            label: Text(name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _userNameController.text = name;
                                setState(() {});
                              }
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Theme.of(context).colorScheme.primaryContainer,
                            checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'You Owe',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(totalYouOwe),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Owed to You',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(totalOwedToYou),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Net Balance
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: netBalance >= 0 
                      ? Colors.green.shade100 
                      : Colors.orange.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Balance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Row(
                          children: [
                            Icon(
                              netBalance >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                              color: netBalance >= 0 ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              CurrencyFormatter.format(netBalance.abs()),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: netBalance >= 0 ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // People List
              Expanded(
                child: personBalances.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No balances found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Make sure your name matches exactly in groups',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: personBalances.length,
                        itemBuilder: (context, index) {
                          final personBalance = personBalances[index];
                          final isOwed = personBalance.totalBalance > 0;
                          final color = isOwed ? Colors.green : Colors.red;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: color.shade100,
                                child: Icon(
                                  isOwed ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: color.shade700,
                                ),
                              ),
                              title: Text(
                                personBalance.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                isOwed
                                    ? 'owes you ${CurrencyFormatter.format(personBalance.totalBalance)}'
                                    : 'you owe ${CurrencyFormatter.format(personBalance.totalBalance.abs())}',
                              ),
                              trailing: Text(
                                CurrencyFormatter.format(personBalance.totalBalance.abs()),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color.shade700,
                                    ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Groups with ${personBalance.name}:',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...personBalance.groups.map((groupDetail) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  groupDetail.group.name,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                              Text(
                                                CurrencyFormatter.format(groupDetail.amount.abs()),
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: groupDetail.amount > 0 
                                                          ? Colors.green.shade700 
                                                          : Colors.red.shade700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

