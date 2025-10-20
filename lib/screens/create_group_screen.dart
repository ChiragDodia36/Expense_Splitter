import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../utils/validators.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final List<TextEditingController> _memberControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMemberField() {
    setState(() {
      _memberControllers.add(TextEditingController());
    });
  }

  void _removeMemberField(int index) {
    if (_memberControllers.length > 2) {
      setState(() {
        _memberControllers[index].dispose();
        _memberControllers.removeAt(index);
      });
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final memberNames = _memberControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // Validate at least 2 members
    final membersError = Validators.validateMinMembers(memberNames);
    if (membersError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(membersError)),
      );
      return;
    }

    // Check for duplicates
    final duplicateError = Validators.validateDuplicateMembers(memberNames);
    if (duplicateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(duplicateError)),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      await groupProvider.createGroup(
        name: _groupNameController.text.trim(),
        memberNames: memberNames,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Group Name Section
            Text(
              'Group Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Trip to NYC',
                prefixIcon: Icon(Icons.group),
              ),
              validator: Validators.validateGroupName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _addMemberField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Member'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Member Fields
            ..._memberControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Member ${index + 1}',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return null; // Allow empty for optional members
                          }
                          return Validators.validateMemberName(value);
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    if (_memberControllers.length > 2) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () => _removeMemberField(index),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You need at least 2 members to create a group.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: _isCreating ? null : _createGroup,
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create Group'),
          ),
        ),
      ),
    );
  }
}

