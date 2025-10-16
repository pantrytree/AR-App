import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/viewmodels/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  // Alert dialog function
  Future<void> _showMyDialog(BuildContext context, String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

              // Error dialog handling
              if (viewModel.errorMessage.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await _showMyDialog(context, viewModel.errorMessage);
                  viewModel.clearError(); // Clear error after showing dialog
                });
              }

              return Scaffold(
                backgroundColor: AppColors.splashBrackground,
                body: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              )
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: viewModel.emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryDarkBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.white.withOpacity(0.9),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: TextStyle(
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: viewModel.passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryDarkBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.white.withOpacity(0.9),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              obscureText: true,
                              style: TextStyle(
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          viewModel.isLoading
                              ? CircularProgressIndicator(
                            color: AppColors.white,
                          )
                              : ElevatedButton(
                            onPressed: viewModel.login,
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
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: viewModel.onForgotPasswordTapped,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                            ),
                            child: Text('Forgot your password?'),
                          ),
                          const SizedBox(height: 16),
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
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
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
