import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';
import '/viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ForgotPasswordViewModel _viewModel = ForgotPasswordViewModel();

  @override
  void dispose() {
    _viewModel.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextComponents.forgotPasswordTitle),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Description
              Text(
                TextComponents.forgotPasswordDescription,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextFormField(
                controller: _viewModel.emailController,
                decoration: InputDecoration(
                  labelText: TextComponents.emailFieldLabel,
                  hintText: TextComponents.emailFieldHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _viewModel.errorMessage,
                ),
              ),

              const SizedBox(height: 30),

              // Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _viewModel.sendResetLink();
                    setState(() {}); // Refresh UI to show errors
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(TextComponents.sendResetLinkButton),
                ),
              ),

              const Spacer(),

              // Sign Up Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(TextComponents.noAccountText),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/sign_up");
                    },
                    child: Text(TextComponents.signUpButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}