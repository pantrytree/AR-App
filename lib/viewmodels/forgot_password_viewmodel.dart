import 'package:flutter/material.dart';
import '/utils/text_components.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();

  String? errorMessage;

  /// Function to handle sending password reset link
  void sendResetLink() {
    final email = emailController.text.trim();

    // Simple validation
    if (email.isEmpty) {
      errorMessage = "Please enter your email";
      notifyListeners();
      return;
    }

    // Placeholder for backend call
    print("Sending reset link to $email");

    // Clear error if valid
    errorMessage = null;
    notifyListeners();
  }

  /// Dispose the conntroller
  void disposeControllers() {
    emailController.dispose();
  }
}