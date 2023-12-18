class FormValidator {
  static FormValidator? _instance;

  factory FormValidator() => _instance ??= FormValidator._();

  FormValidator._();

  ///Require 8 characters minimum password length and at least:
  /// - 1 uppercase letter
  /// - 1 lowercase letter
  /// - 1 number
  String? validatePassword(String? value) {
    String pattern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
    RegExp regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 8) {
      return "Minimum password length is 8 characters";
    } else if (!regExp.hasMatch(value)) {
      return "Password requires at least one uppercase letter, one lowercase letter and one number";
    }
    return null;
  }

  /// Validates proper email form
  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }
}
