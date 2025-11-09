import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../../utils/text_components.dart';
import '../../theme/theme.dart';
import '../../../viewmodels/forgot_password_viewmodel.dart';

// ForgotPasswordPage is a stateless widget that handles the password reset flow
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to manage the viewmodel state
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<ForgotPasswordViewModel>(
            builder: (context, viewModel, child) {
              // Handle navigation logic after the frame is built
              // This ensures navigation happens after the current build cycle completes
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
                    // Conditional back button behavior:
                    // - If we can go back in the flow, go to previous step
                    // - Otherwise, pop the entire page
                    onPressed: viewModel.canGoBack
                        ? () => viewModel.goToPreviousStep()
                        : () => Navigator.pop(context),
                  ),
                  elevation: 0, // Remove app bar shadow
                ),
                body: _buildBody(context, viewModel),
              );
            },
          );
        },
      ),
    );
  }

  // Builds the main content body of the page
  Widget _buildBody(BuildContext context, ForgotPasswordViewModel viewModel) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Column only takes needed space
            children: [
              const SizedBox(height: 32),

              // Progress indicator showing current step in the flow
              _buildProgressIndicator(context, viewModel),

              const SizedBox(height: 32),

              // Title and description section
              _buildTitleSection(context, viewModel),

              const SizedBox(height: 32),

              // Dynamic form section that changes based on current step
              _buildCurrentStepForm(context, viewModel),

              const SizedBox(height: 24),

              // Error and success messages display
              _buildMessages(context, viewModel),

              const SizedBox(height: 16),

              // Primary action button (changes based on step)
              _buildActionButton(context, viewModel),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the title and description section that changes per step
  Widget _buildTitleSection(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main title for the current step
        Text(
          viewModel.currentStepTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),

        const SizedBox(height: 8),

        // Conditional description based on current step
        if (viewModel.currentStep == 1)
          // Special rich text description for step 1 (link sent)
          _buildEmailDescription(context, viewModel)
        else
          // Regular description for other steps
          Text(
            viewModel.currentStepDescription,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 16,
              height: 1.5, // Line height for better readability
            ),
          ),
      ],
    );
  }

  // Builds a rich text description for the email sent step
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
          // Highlight the email address for emphasis
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

  // Builds the progress indicator showing current step in the flow
  Widget _buildProgressIndicator(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 0: Email input
        _buildProgressStep(context, 0, 'Email', viewModel.currentStep),
        _buildProgressConnector(context),
        // Step 1: Link sent
        _buildProgressStep(context, 1, 'Link Sent', viewModel.currentStep),
      ],
    );
  }

  // Builds an individual progress step circle with label
  Widget _buildProgressStep(BuildContext context, int step, String label, int currentStep) {
    final isActive = step == currentStep; // Current step
    final isCompleted = step < currentStep; // Completed step

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? AppColors.getPrimaryColor(context) // Active/completed color
                : AppColors.getSecondaryTextColor(context).withOpacity(0.3), // Inactive color
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16) // Checkmark for completed
                : Text(
              (step + 1).toString(), // Step number
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Step label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted
                ? AppColors.getPrimaryColor(context) // Active/completed color
                : AppColors.getSecondaryTextColor(context).withOpacity(0.5), // Inactive color
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Builds the connector line between progress steps
  Widget _buildProgressConnector(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.getSecondaryTextColor(context).withOpacity(0.3),
    );
  }

  // Builds the dynamic form content based on current step
  Widget _buildCurrentStepForm(BuildContext context, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildEmailStep(context, viewModel); // Email input step
      case 1:
        return _buildLinkSentStep(context, viewModel); // Link sent step
      default:
        return _buildEmailStep(context, viewModel); // Fallback to email step
    }
  }

  // Builds the email input step form
  Widget _buildEmailStep(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Container(
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
              onChanged: (value) => viewModel.setEmail(value), // Update email in viewmodel
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
                  borderSide: BorderSide.none, // Remove default border
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

  // Builds the link sent confirmation step
  Widget _buildLinkSentStep(BuildContext context, ForgotPasswordViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Success icon
          Icon(
            Icons.mark_email_read_outlined,
            size: 80,
            color: AppColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 20),
          // Resend link option
          GestureDetector(
            onTap: viewModel.isLoading ? null : () => viewModel.resendResetLink(),
            child: Text(
              "Didn't receive the link? Resend",
              style: TextStyle(
                color: AppColors.getPrimaryColor(context),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Return to login option
          GestureDetector(
            onTap: () => _navigateToLogin(context, viewModel.email),
            child: Text(
              "Return to Login",
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Builds error and success message displays
  Widget _buildMessages(BuildContext context, ForgotPasswordViewModel viewModel) {
    // Show error message if exists
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

    // Show success message if exists
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

    // Return empty container if no messages
    return const SizedBox.shrink();
  }

  // Builds the primary action button (changes based on step)
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
          elevation: 0, // Remove button shadow
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
          viewModel.primaryButtonText, // Dynamic button text
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Handles the primary button action based on current step
  void _handlePrimaryAction(BuildContext context, ForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        viewModel.sendPasswordResetEmail(); // Send reset email
        break;
      case 1:
        viewModel.verifyResetCompletion(); // Verify completion
        break;
    }
  }

  // Navigates back to login page with email parameter
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
