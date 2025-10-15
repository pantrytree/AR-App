import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '../../../utils/text_components.dart';
import '../../../viewmodels/logout_viewmodel.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LogoutViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Scaffold(
            backgroundColor: AppColors.getBackgroundColor(context),
            body: Consumer<LogoutViewModel>(
              builder: (context, viewModel, child) {
                return SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 80),

                          // Logout Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout,
                              size: 40,
                              color: AppColors.getPrimaryColor(context),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Main Question
                          Text(
                            TextComponents.logoutConfirmationQuestion,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Description Text
                          Text(
                            TextComponents.logoutDetailedDescription,
                            style: TextStyle(
                              color: AppColors.getSecondaryTextColor(context),
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Add Another Account Button
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            },
                            child: Text(
                              TextComponents.addAnotherAccount,
                              style: TextStyle(
                                color: AppColors.getPrimaryColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Row(
                              children: [
                                // Logout Button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading ? null : () {
                                      // Navigate to login page
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/login', (route) => false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.getPrimaryColor(context),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                                      TextComponents.logoutButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Cancel Button
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: viewModel.isLoading ? null : () {
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.getTextColor(context),
                                      side: BorderSide(
                                          color: AppColors.getTextColor(context).withOpacity(0.3)
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: AppColors.getCardBackground(context),
                                    ),
                                    child: Text(
                                      TextComponents.cancelButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}