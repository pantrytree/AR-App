import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/viewmodels/sign_up_viewmodel.dart';

class SignUpPage extends StatelessWidget {
  // Alert dialog function
  Future<void> _showMyDialog(BuildContext context, String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Failed'),
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
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (_) => SignUpViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<SignUpViewModel>(
            builder: (context, model, child) {
              // Navigation handling
              if (model.navigateToRoute != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, model.navigateToRoute!);
                  model.clearNavigation();
                });
              }

              // Error dialog handling
              if (model.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await _showMyDialog(context, model.errorMessage!);
                  model.clearError(); // Clear error after showing dialog
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
                                  ),
                                  obscureText: true,
                                  onChanged: model.setPassword,
                                  validator: model.passwordValidator,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: model.loading ? null : model.signUp,
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
                              onTap: model.onBackButtonTapped,
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
