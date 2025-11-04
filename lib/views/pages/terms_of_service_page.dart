import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getAppBarForeground(context),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Terms of Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getSecondaryTextColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, '1. Acceptance of Terms'),
              _buildSectionContent(context,
                'By accessing or using our application, you agree to be bound by these '
                    'Terms of Service and our Privacy Policy. If you do not agree to these terms, '
                    'please do not use our application.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '2. User Accounts'),
              _buildSectionContent(context,
                'To use certain features of our app, you must create an account. You agree to:\n\n'
                    '• Provide accurate and complete information\n'
                    '• Maintain the security of your password\n'
                    '• Accept responsibility for all activities under your account\n'
                    '• Not share your account credentials with others\n'
                    '• Not create multiple accounts for abusive purposes',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '3. User Conduct'),
              _buildSectionContent(context,
                'You agree not to:\n\n'
                    '• Use the app for any illegal purpose\n'
                    '• Harass, abuse, or harm other users\n'
                    '• Upload or share inappropriate content\n'
                    '• Attempt to gain unauthorized access to other accounts\n'
                    '• Interfere with the proper functioning of the app\n'
                    '• Use automated systems to access the app\n'
                    '• Violate any applicable laws or regulations',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '4. Intellectual Property'),
              _buildSectionContent(context,
                'All content, features, and functionality of our app are owned by us and '
                    'are protected by international copyright, trademark, and other intellectual '
                    'property laws. You may not copy, modify, distribute, or create derivative '
                    'works without our explicit permission.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '5. User Content'),
              _buildSectionContent(context,
                'By submitting content to our app, you grant us a worldwide, non-exclusive, '
                    'royalty-free license to use, display, and distribute your content in connection '
                    'with operating and improving our services. You retain all ownership rights to '
                    'your content.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '6. Termination'),
              _buildSectionContent(context,
                'We may suspend or terminate your account and access to our app at our '
                    'sole discretion, without notice, for conduct that we believe violates '
                    'these Terms of Service or is harmful to other users, us, or third parties, '
                    'or for any other reason.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '7. Disclaimer of Warranties'),
              _buildSectionContent(context,
                'Our app is provided "as is" and "as available" without warranties of any '
                    'kind, either express or implied. We do not guarantee that the app will be '
                    'uninterrupted, timely, secure, or error-free.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '8. Limitation of Liability'),
              _buildSectionContent(context,
                'To the fullest extent permitted by law, we shall not be liable for any '
                    'indirect, incidental, special, consequential, or punitive damages, or any '
                    'loss of profits or revenues, whether incurred directly or indirectly, or '
                    'any loss of data, use, goodwill, or other intangible losses.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '9. Changes to Terms'),
              _buildSectionContent(context,
                'We reserve the right to modify these terms at any time. We will notify '
                    'users of significant changes through the app or via email. Continued use '
                    'of the app after changes constitutes acceptance of the new terms.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '10. Governing Law'),
              _buildSectionContent(context,
                'These Terms shall be governed by the laws of [Your Country/State] without '
                    'regard to its conflict of law provisions. Any disputes shall be resolved '
                    'in the courts located in [Your City, Country/State].',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(context, '11. Contact Information'),
              _buildSectionContent(context,
                'If you have any questions about these Terms of Service, please contact us at:\n\n'
                    'legal@yourapp.com\n\n'
                    'We will respond to your inquiry within 30 days.',
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acknowledgement',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By using our application, you acknowledge that you have read, '
                          'understood, and agree to be bound by these Terms of Service.',
                      style: TextStyle(
                        color: AppColors.getSecondaryTextColor(context),
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
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextColor(context),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: AppColors.getTextColor(context),
      ),
    );
  }
}