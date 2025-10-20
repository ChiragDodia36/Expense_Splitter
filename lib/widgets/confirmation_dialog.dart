import 'package:flutter/material.dart';

class ConfirmationDialog {
  /// Show a confirmation dialog
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool isDangerous = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show delete group confirmation
  static Future<bool> confirmDeleteGroup(
    BuildContext context,
    String groupName,
  ) {
    return show(
      context: context,
      title: 'Delete Group?',
      message: 'Are you sure you want to delete "$groupName"? '
          'All expenses and data will be permanently lost.',
      confirmText: 'Delete',
    );
  }

  /// Show delete expense confirmation
  static Future<bool> confirmDeleteExpense(
    BuildContext context,
    String expenseDescription,
  ) {
    return show(
      context: context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete "$expenseDescription"?',
      confirmText: 'Delete',
    );
  }

  /// Show delete member confirmation
  static Future<bool> confirmDeleteMember(
    BuildContext context,
    String memberName,
  ) {
    return show(
      context: context,
      title: 'Remove Member?',
      message: 'Are you sure you want to remove "$memberName"? '
          'They will be removed from all expenses.',
      confirmText: 'Remove',
    );
  }

  /// Show general error dialog
  static Future<void> showError(
    BuildContext context, {
    String title = 'Error',
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success message
  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

