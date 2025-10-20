import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../models/expense.dart';
import '../models/split.dart' as models;
import '../utils/validators.dart';
import '../utils/currency_formatter.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  
  String? _selectedPayerId;
  final Set<String> _selectedParticipants = {};
  bool _isEqualSplit = true;
  bool _isSaving = false;
  
  // For custom splits
  final Map<String, TextEditingController> _customSplitControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing expense data
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _selectedPayerId = widget.expense.payerId;
    
    // Initialize participants from splits
    for (var split in widget.expense.splits) {
      _selectedParticipants.add(split.memberId);
    }
    
    // Check if it's an equal split
    _isEqualSplit = _checkIfEqualSplit();
    
    // If custom split, initialize controllers
    if (!_isEqualSplit) {
      for (var split in widget.expense.splits) {
        _customSplitControllers[split.memberId] = 
            TextEditingController(text: split.amount.toStringAsFixed(2));
      }
    }
  }

  bool _checkIfEqualSplit() {
    if (widget.expense.splits.isEmpty) return true;
    
    final expectedEqualAmount = widget.expense.amount / widget.expense.splits.length;
    
    // Check if all splits are equal (with small tolerance for floating point)
    return widget.expense.splits.every((split) => 
        (split.amount - expectedEqualAmount).abs() < 0.01);
  }

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
          if (!_customSplitControllers.containsKey(memberId)) {
            // Try to find existing split amount
            final existingSplit = widget.expense.splits
                .where((s) => s.memberId == memberId)
                .firstOrNull;
            
            _customSplitControllers[memberId] = TextEditingController(
              text: existingSplit?.amount.toStringAsFixed(2) ?? '',
            );
          }
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

      List<models.Split> splits;

      if (_isEqualSplit) {
        // Equal split
        final splitAmount = amount / _selectedParticipants.length;
        splits = _selectedParticipants
            .map((id) => models.Split(memberId: id, amount: splitAmount))
            .toList();
      } else {
        // Custom split
        splits = <models.Split>[];
        double totalSplit = 0;

        for (var memberId in _selectedParticipants) {
          final splitAmount = double.parse(_customSplitControllers[memberId]!.text);
          splits.add(models.Split(memberId: memberId, amount: splitAmount));
          totalSplit += splitAmount;
        }

        // Validate split sum
        if ((totalSplit - amount).abs() > 0.01) {
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Split amounts (${CurrencyFormatter.format(totalSplit)}) '
                  'must equal total amount (${CurrencyFormatter.format(amount)})',
                ),
              ),
            );
          }
          return;
        }
      }

      // Create updated expense
      final updatedExpense = widget.expense.copyWith(
        description: _descriptionController.text.trim(),
        amount: amount,
        payerId: _selectedPayerId,
        splits: splits,
      );

      await groupProvider.updateExpense(group.id, updatedExpense);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated successfully!'),
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
        title: const Text('Edit Expense'),
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
                : const Text('Save Changes'),
          ),
        ),
      ),
    );
  }
}

