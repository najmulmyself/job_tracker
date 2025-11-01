class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateCompanyName(String? value) {
    return validateRequired(value, 'Company name');
  }

  static String? validateJobTitle(String? value) {
    return validateRequired(value, 'Job title');
  }

  static String? validateJobDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Job description is required';
    }
    if (value.length < 10) {
      return 'Job description must be at least 10 characters';
    }
    return null;
  }

  static String? validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove commas and spaces
    final cleanValue = value.replaceAll(RegExp(r'[,\s]'), '');

    if (double.tryParse(cleanValue) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > 1000) {
      return 'Notes must be less than 1000 characters';
    }
    return null;
  }
}
