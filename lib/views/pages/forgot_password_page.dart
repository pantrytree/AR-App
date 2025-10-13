import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';
import '/viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          // Handle navigation
          if (viewModel.navigateToRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(
                context,
                viewModel.navigateToRoute!,
                arguments: viewModel.navigationArguments,
              ).then((_) => viewModel.clearNavigation());
            });
          }

          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            appBar: AppBar(
              backgroundColor: AppColors.secondaryBackground,
              title: Text(
                TextComponents.forgotPasswordTitle,
                style: TextStyle(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 0,
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ForgotPasswordViewModel viewModel) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Description
              Text(
                TextComponents.forgotPasswordDescription,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => viewModel.setEmail(value),
                  decoration: InputDecoration(
                    labelText: TextComponents.emailFieldLabel,
                    labelStyle: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                    hintText: TextComponents.emailFieldHint,
                    hintStyle: TextStyle(
                      color: AppColors.textLight.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF3F0FF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.primaryDarkBlue,
                    fontSize: 16,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              const SizedBox(height: 24),

              // Error Message
              if (viewModel.hasError)
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

              // Success Message
              if (viewModel.successMessage != null)
                Text(
                  viewModel.successMessage!,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Send Reset Link Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => viewModel.sendPasswordResetEmail(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary, // Same color as logout button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0, // Same as logout button
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      TextComponents.sendResetLinkButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}