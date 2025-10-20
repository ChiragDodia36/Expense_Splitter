class Validators {
  /// Validate group name
  static String? validateGroupName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Group name is required';
    }
    if (value.trim().length < 2) {
      return 'Group name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Group name must be less than 50 characters';
    }
    return null;
  }

  /// Validate member name
  static String? validateMemberName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Member name is required';
    }
    if (value.trim().length < 2) {
      return 'Member name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Member name must be less than 30 characters';
    }
    return null;
  }

  /// Validate expense description
  static String? validateExpenseDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 2) {
      return 'Description must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Description must be less than 100 characters';
    }
    return null;
  }

  /// Validate expense amount
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    // Try to parse the amount
    final amount = double.tryParse(value.trim());
    
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 999999.99) {
      return 'Amount is too large';
    }

    // Check decimal places
    final parts = value.trim().split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Maximum 2 decimal places allowed';
    }

    return null;
  }

  /// Validate split amount
  static String? validateSplitAmount(String? value, {double? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value.trim());
    
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Amount exceeds total';
    }

    return null;
  }

  /// Validate that split amounts sum to total
  static String? validateSplitSum(List<double> splitAmounts, double totalAmount) {
    final sum = splitAmounts.fold(0.0, (a, b) => a + b);
    final difference = (sum - totalAmount).abs();
    
    // Allow small floating point errors (1 cent)
    if (difference > 0.01) {
      return 'Split amounts must equal total expense amount';
    }

    return null;
  }

  /// Validate at least one participant is selected
  static String? validateParticipants(List<String> participantIds) {
    if (participantIds.isEmpty) {
      return 'Please select at least one participant';
    }
    return null;
  }

  /// Validate at least two members in group
  static String? validateMinMembers(List<String> memberNames) {
    final validMembers = memberNames.where((name) => name.trim().isNotEmpty).toList();
    if (validMembers.length < 2) {
      return 'At least 2 members are required';
    }
    return null;
  }

  /// Check for duplicate member names
  static String? validateDuplicateMembers(List<String> memberNames) {
    final trimmedNames = memberNames.map((name) => name.trim().toLowerCase()).toList();
    final uniqueNames = trimmedNames.toSet();
    
    if (trimmedNames.length != uniqueNames.length) {
      return 'Duplicate member names are not allowed';
    }
    
    return null;
  }

  /// Validate email (optional, for future features)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }
}

