class Validators {
  const Validators._();

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final emptyError = requiredField(value, 'Email address');
    if (emptyError != null) return emptyError;

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final emptyError = requiredField(value, 'Password');
    if (emptyError != null) return emptyError;

    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[^\w\s]').hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final emptyError = requiredField(value, 'Confirm password');
    if (emptyError != null) return emptyError;

    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
