import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../../utils/text_components.dart';
import '../../theme/theme.dart';
import '../../../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<ForgotPasswordViewModel>(
            builder: (context, viewModel, child) {
              // Handle navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.navigateToRoute != null) {
                  Navigator.pushNamed(
                    context,
                    viewModel.navigateToRoute!,
                    arguments: viewModel.navigationArguments,
                  ).then((_) => viewModel.clearNavigation());
                }
              });

              return Scaffold(
                backgroundColor: AppColors.getBackgroundColor(context),
                appBar: AppBar(
                  backgroundColor: AppColors.getAppBarBackground(context),
                  title: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: AppColors.getAppBarForeground(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.getAppBarForeground(context)
                    ),
                    onPressed: viewModel.canGoBack
                        ? () => viewModel.goToPreviousStep()
                        : () => Navigator.pop(context),
                  ),
                  elevation: 0,
                ),
                body: _buildBody(context, viewModel),
              );
            },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              _buildProgressIndicator(context, viewModel),

              const SizedBox(height: 32),

              Text(
                viewModel.currentStepTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),

              const SizedBox(height: 8),

              if (viewModel.currentStep == 1)
                _buildEmailDescription(context, viewModel)
              else
                Text(
                  viewModel.currentStepDescription,
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

              const SizedBox(height: 32),

              Expanded(
                child: _buildCurrentStepForm(context, viewModel),
              ),

              const SizedBox(height: 24),

              // Error and success messages
              _buildMessages(context, viewModel),

              const SizedBox(height: 16),

              // Action button
              _buildActionButton(context, viewModel),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailDescription(BuildContext context, ForgotPasswordViewModel viewModel) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.getSecondaryTextColor(context),
          fontSize: 16,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: "We've sent a password reset link to:\n\n"),
          TextSpan(
            text: viewModel.email,
            style: TextStyle(
              color: AppColors.getPrimaryColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const TextSpan(text: "\n\nPlease check your email and click the link to reset your password. "),
          const TextSpan(text: "Don't forget to check your spam folder if you can't find it!"),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressStep(context, 0, 'Email', viewModel.currentStep),
        _buildProgressConnector(context),
        _buildProgressStep(context, 1, 'Link Sent', viewModel.currentStep),
      ],
    );
  }

  Widget _buildProgressStep(BuildContext context, int step, String label, int currentStep) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? AppColors.getPrimaryColor(context)
                : AppColors.getSecondaryTextColor(context).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
              (step + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted
                ? AppColors.getPrimaryColor(context)
                : AppColors.getSecondaryTextColor(context).withOpacity(0.5),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.getSecondaryTextColor(context).withOpacity(0.3),
    );
  }

  Widget _buildCurrentStepForm(BuildContext context, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildEmailStep(context, viewModel);
      case 1:
        return _buildLinkSentStep(context, viewModel);
      default:
        return _buildEmailStep(context, viewModel);
    }
  }

  Widget _buildEmailStep(BuildContext context, ForgotPasswordViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.getTextFieldBackground(context),
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
                  color: AppColors.getSecondaryTextColor(context),
                  fontSize: 16,
                ),
                hintText: TextComponents.emailFieldHint,
                hintStyle: TextStyle(
                  color: AppColors.getSecondaryTextColor(context).withOpacity(0.6),
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
                    color: AppColors.getPrimaryColor(context),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.getTextFieldBackground(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 16,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSentStep(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: AppColors.getPrimaryColor(context),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: viewModel.isLoading ? null : () => viewModel.resendResetLink(),
          child: Text(
            "Didn't receive the link? Resend",
            style: TextStyle(
              color: AppColors.getPrimaryColor(context),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _navigateToLogin(context, viewModel.email),
          child: Text(
            "Return to Login",
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages(BuildContext context, ForgotPasswordViewModel viewModel) {
    if (viewModel.hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Text(
          viewModel.errorMessage!,
          style: TextStyle(
            color: AppColors.error,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (viewModel.successMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Text(
          viewModel.successMessage!,
          style: TextStyle(
            color: AppColors.success,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton(BuildContext context, ForgotPasswordViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => _handlePrimaryAction(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
          viewModel.primaryButtonText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _handlePrimaryAction(BuildContext context, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        viewModel.sendPasswordResetEmail();
        break;
      case 1:
        viewModel.verifyResetCompletion();
        break;
    }
  }

  void _navigateToLogin(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      '/login',
      arguments: {
        'message': 'Password reset link sent! Please check your email.',
        'email': email,
      },
    );
  }
}