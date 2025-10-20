import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../models/split.dart' as models;
import '../utils/validators.dart';
import '../utils/currency_formatter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedPayerId;
  final Set<String> _selectedParticipants = {};
  bool _isEqualSplit = true;
  bool _isSaving = false;
  
  // For custom splits
  final Map<String, TextEditingController> _customSplitControllers = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (var controller in _customSplitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleParticipant(String memberId) {
    setState(() {
      if (_selectedParticipants.contains(memberId)) {
        _selectedParticipants.remove(memberId);
        _customSplitControllers[memberId]?.dispose();
        _customSplitControllers.remove(memberId);
      } else {
        _selectedParticipants.add(memberId);
        if (!_isEqualSplit) {
          _customSplitControllers[memberId] = TextEditingController();
        }
      }
    });
  }

  void _toggleSplitType() {
    setState(() {
      _isEqualSplit = !_isEqualSplit;
      
      if (!_isEqualSplit) {
        // Create controllers for custom splits
        for (var memberId in _selectedParticipants) {
          _customSplitControllers[memberId] = TextEditingController();
        }
      } else {
        // Clear custom split controllers
        for (var controller in _customSplitControllers.values) {
          controller.dispose();
        }
        _customSplitControllers.clear();
      }
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    setState(() => _isSaving = true);

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final group = groupProvider.selectedGroup;
      
      if (group == null) throw Exception('No group selected');

      if (_isEqualSplit) {
        // Equal split
        await groupProvider.addExpenseEqualSplit(
          groupId: group.id,
          description: _descriptionController.text.trim(),
          amount: amount,
          payerId: _selectedPayerId!,
          participantIds: _selectedParticipants.toList(),
        );
      } else {
        // Custom split
        final splits = <models.Split>[];
        double totalSplit = 0;

        for (var memberId in _selectedParticipants) {
          final splitAmount = double.parse(_customSplitControllers[memberId]!.text);
          splits.add(models.Split(memberId: memberId, amount: splitAmount));
          totalSplit += splitAmount;
        }

        // Validate split sum
        if ((totalSplit - amount).abs() > 0.01) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Split amounts (${CurrencyFormatter.format(totalSplit)}) '
                'must equal total amount (${CurrencyFormatter.format(amount)})',
              ),
            ),
          );
          return;
        }

        await groupProvider.addExpenseCustomSplit(
          groupId: group.id,
          description: _descriptionController.text.trim(),
          amount: amount,
          payerId: _selectedPayerId!,
          splits: splits,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  double? get _totalAmount {
    final text = _amountController.text;
    return double.tryParse(text);
  }

  double get _remainingAmount {
    final total = _totalAmount ?? 0;
    double allocated = 0;
    
    for (var controller in _customSplitControllers.values) {
      allocated += double.tryParse(controller.text) ?? 0;
    }
    
    return total - allocated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          final group = groupProvider.selectedGroup;
          
          if (group == null) {
            return const Center(child: Text('No group selected'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Dinner at restaurant',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: Validators.validateExpenseDescription,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: Validators.validateAmount,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Who Paid?
                Text(
                  'Who Paid?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.members.map((member) {
                    final isSelected = _selectedPayerId == member.id;
                    return ChoiceChip(
                      label: Text(member.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedPayerId = member.id);
                      },
                      avatar: isSelected ? null : CircleAvatar(
                        backgroundColor: Color(member.avatarColorValue ?? 0xFF6200EE),
                        child: Text(
                          member.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Split Type Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Split Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Equal'),
                          icon: Icon(Icons.pie_chart),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Custom'),
                          icon: Icon(Icons.tune),
                        ),
                      ],
                      selected: {_isEqualSplit},
                      onSelectionChanged: (Set<bool> selected) {
                        _toggleSplitType();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Participants
                Text(
                  'Split Between',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Participant Selection
                ...group.members.map((member) {
                  final isSelected = _selectedParticipants.contains(member.id);
                  
                  if (_isEqualSplit) {
                    // Equal split - just checkboxes
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) => _toggleParticipant(member.id),
                      title: Text(member.name),
                      subtitle: _totalAmount != null && isSelected && _selectedParticipants.isNotEmpty
                          ? Text(
                              'Share: ${CurrencyFormatter.format(_totalAmount! / _selectedParticipants.length)}',
                            )
                          : null,
                      secondary: CircleAvatar(
                        backgroundColor: Color(member.avatarColorValue ?? 0xFF6200EE),
                        child: Text(
                          member.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    // Custom split - checkboxes with input fields
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (checked) => _toggleParticipant(member.id),
                            ),
                            CircleAvatar(
                              backgroundColor: Color(member.avatarColorValue ?? 0xFF6200EE),
                              radius: 16,
                              child: Text(
                                member.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(member.name)),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: _customSplitControllers[member.id],
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                    prefixText: '\$ ',
                                    isDense: true,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  validator: (value) => Validators.validateSplitAmount(
                                    value,
                                    maxAmount: _totalAmount,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                }),

                // Remaining amount indicator (for custom splits)
                if (!_isEqualSplit && _selectedParticipants.isNotEmpty && _totalAmount != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: _remainingAmount.abs() < 0.01
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            CurrencyFormatter.format(_remainingAmount),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _remainingAmount.abs() < 0.01
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _saveExpense,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Add Expense'),
          ),
        ),
      ),
    );
  }
}

