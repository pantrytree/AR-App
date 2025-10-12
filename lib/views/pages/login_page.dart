import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '/viewmodels/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          // Handle navigation when flagged
          if (viewModel.navigateToRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, viewModel.navigateToRoute!);
              viewModel.clearNavigation();
            });
          }

          return Scaffold(
            backgroundColor: AppColors.primaryPurple,
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      SizedBox(height: 32),
                      if (viewModel.errorMessage.isNotEmpty)
                        Text(
                          viewModel.errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      TextField(
                        controller: viewModel.emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: viewModel.passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      SizedBox(height: 32),
                      viewModel.isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: viewModel.login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[900],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: viewModel.onForgotPasswordTapped,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple[900],
                        ),
                        child: Text('Forgot your password?'),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: viewModel.onSignUpTapped,
                            child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: Colors.white.withOpacity(0.8),
                        shape: CircleBorder(),
                        child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: viewModel.onBackButtonTapped,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
      ),
    );
  }
}
