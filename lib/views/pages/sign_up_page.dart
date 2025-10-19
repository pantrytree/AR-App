import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '../../../viewmodels/sign_up_viewmodel.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (_) => SignUpViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<SignUpViewModel>(
            builder: (context, model, child) {
              if (model.navigateToRoute != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, model.navigateToRoute!);
                  model.clearNavigation();
                });
              }

              return Scaffold(
                body: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.splashBrackground,
                            AppColors.splashBrackground,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Form(
                          key: model.formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Personal details',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Name Field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: AppColors.primaryDarkBlue),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(color: AppColors.mediumGrey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  onChanged: model.setName,
                                  validator: model.nameValidator,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: AppColors.primaryDarkBlue),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: AppColors.mediumGrey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  onChanged: model.setEmail,
                                  validator: model.emailValidator,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password Field with Requirements
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: AppColors.primaryDarkBlue),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: AppColors.mediumGrey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: AppColors.mediumGrey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _showPasswordRequirements(context);
                                      },
                                    ),
                                  ),
                                  obscureText: true,
                                  onChanged: model.setPassword,
                                  validator: model.passwordValidator,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Password Requirements Hint
                              _buildPasswordRequirements(model.password),
                              const SizedBox(height: 8),

                              // Confirm Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: AppColors.primaryDarkBlue),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm password',
                                    labelStyle: TextStyle(color: AppColors.mediumGrey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  obscureText: true,
                                  onChanged: model.setConfirmPassword,
                                  validator: model.confirmPasswordValidator,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Error Message
                              if (model.errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    model.errorMessage!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 8),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:  model.loading
                                      ? null
                                      : () async {
                                    // Validate and submit
                                    if (model.formKey.currentState!.validate()) {
                                      await model.signUp();
                                    }
                                  },
                                  child: model.loading
                                      ? CircularProgressIndicator(
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                                  )
                                      : Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.signupButtonBackground,
                                    foregroundColor: AppColors.signupButtonText,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign In Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  GestureDetector(
                                    onTap: model.onSignInTapped,
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: AppColors.white.withOpacity(0.8),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.pushReplacementNamed(context, '/splash2'),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.close, color: Colors.black, size: 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Password Requirements Widget
  Widget _buildPasswordRequirements(String password) {
    final requirements = [
      _Requirement(
        text: 'At least 8 characters',
        fulfilled: password.length >= 8,
      ),
      _Requirement(
        text: 'One uppercase letter',
        fulfilled: RegExp(r'[A-Z]').hasMatch(password),
      ),
      _Requirement(
        text: 'One lowercase letter',
        fulfilled: RegExp(r'[a-z]').hasMatch(password),
      ),
      _Requirement(
        text: 'One number',
        fulfilled: RegExp(r'[0-9]').hasMatch(password),
      ),
      _Requirement(
        text: 'One special character',
        fulfilled: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must contain:',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        ...requirements.map((req) => Row(
          children: [
            Icon(
              req.fulfilled ? Icons.check_circle : Icons.circle_outlined,
              color: req.fulfilled ? Colors.green : AppColors.white.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              req.text,
              style: TextStyle(
                color: req.fulfilled ? Colors.green : AppColors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        )),
      ],
    );
  }

  // Show Password Requirements Dialog
  void _showPasswordRequirements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Password Requirements'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequirementItem('At least 8 characters'),
            _buildRequirementItem('One uppercase letter (A-Z)'),
            _buildRequirementItem('One lowercase letter (a-z)'),
            _buildRequirementItem('One number (0-9)'),
            _buildRequirementItem('One special character (!@#\$%^&*)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _Requirement {
  final String text;
  final bool fulfilled;

  _Requirement({required this.text, required this.fulfilled});
}