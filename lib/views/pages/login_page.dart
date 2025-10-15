import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/viewmodels/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              // Handle navigation when flagged
              if (viewModel.navigateToRoute != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, viewModel.navigateToRoute!);
                  viewModel.clearNavigation();
                });
              }

              return Scaffold(
                backgroundColor: AppColors.splashBrackground,
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  )
                              ),
                              const SizedBox(height: 32),

                              // Error Message
                              if (viewModel.errorMessage.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          viewModel.errorMessage,
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Email Field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  controller: viewModel.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: viewModel.validateEmail,
                                  onChanged: (_) {
                                    if (viewModel.errorMessage.isNotEmpty) {
                                      viewModel.clearError();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.primaryDarkBlue.withOpacity(0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextFormField(
                                  controller: viewModel.passwordController,
                                  validator: viewModel.validatePassword,
                                  onChanged: (_) {
                                    if (viewModel.errorMessage.isNotEmpty) {
                                      viewModel.clearError();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.primaryDarkBlue.withOpacity(0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  obscureText: true,
                                  style: TextStyle(
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Login Button
                              viewModel.isLoading
                                  ? CircularProgressIndicator(
                                color: AppColors.white,
                              )
                                  : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    viewModel.login();
                                  }
                                },
                                child: Text(
                                  'Login',
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
                                  elevation: 2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Forgot Password
                              TextButton(
                                onPressed: viewModel.onForgotPasswordTapped,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                ),
                                child: Text('Forgot your password?'),
                              ),
                              const SizedBox(height: 16),

                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: viewModel.onSignUpTapped,
                                    child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                          decoration: TextDecoration.underline,
                                        )
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                              onTap: viewModel.onBackButtonTapped,
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
}