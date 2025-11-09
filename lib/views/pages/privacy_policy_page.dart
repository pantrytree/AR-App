import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
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

              // Section 1: Information We Collect
              _buildSectionTitle(context, '1. Information We Collect'),
              _buildSectionContent(context,
                'We collect information you provide directly to us when you use our app, '
                    'including:\n\n'
                    '• Account Information: When you create an account, we collect your name, '
                    'email address, and other profile information.\n'
                    '• Content: We collect the content you create, upload, or share through our app.\n'
                    '• Usage Information: We collect information about how you use our app, '
                    'including features you use and time spent.\n'
                    '• Device Information: We collect device-specific information such as '
                    'operating system version and device identifiers.',
              ),

              const SizedBox(height: 24),

              // Section 2: How We Use Your Information
              _buildSectionTitle(context, '2. How We Use Your Information'),
              _buildSectionContent(context,
                'We use the information we collect to:\n\n'
                    '• Provide, maintain, and improve our services\n'
                    '• Develop new features and functionality\n'
                    '• Personalize your experience\n'
                    '• Communicate with you about updates and support\n'
                    '• Ensure the security and safety of our platform\n'
                    '• Comply with legal obligations',
              ),

              const SizedBox(height: 24),

              // Section 3: Information Sharing
              _buildSectionTitle(context, '3. Information Sharing'),
              _buildSectionContent(context,
                'We do not sell your personal information. We may share your information in '
                    'the following circumstances:\n\n'
                    '• With your consent\n'
                    '• With service providers who assist in operating our app\n'
                    '• To comply with legal requirements\n'
                    '• To protect our rights and the safety of our users\n'
                    '• In connection with a business transfer or merger',
              ),

              const SizedBox(height: 24),

              // Section 4: Data Security
              _buildSectionTitle(context, '4. Data Security'),
              _buildSectionContent(context,
                'We implement appropriate security measures to protect your personal '
                    'information from unauthorized access, alteration, disclosure, or destruction. '
                    'However, no method of transmission over the Internet or electronic storage '
                    'is 100% secure, and we cannot guarantee absolute security.',
              ),

              const SizedBox(height: 24),

              // Section 5: Your Rights
              _buildSectionTitle(context, '5. Your Rights'),
              _buildSectionContent(context,
                'You have the right to:\n\n'
                    '• Access and receive a copy of your personal data\n'
                    '• Correct inaccurate or incomplete information\n'
                    '• Delete your personal data\n'
                    '• Restrict or object to processing of your data\n'
                    '• Data portability\n'
                    '• Withdraw consent at any time',
              ),

              const SizedBox(height: 24),

              // Section 6: Contact Us
              _buildSectionTitle(context, '6. Contact Us'),
              _buildSectionContent(context,
                'If you have any questions about this Privacy Policy or our data practices, '
                    'please contact us at:\n\n'
                    'privacy@yourapp.com\n\n'
                    'We will respond to your inquiry within 30 days.',
              ),

              const SizedBox(height: 32),

              // User Acknowledgement Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'By using our app, you acknowledge that you have read and understood '
                      'this Privacy Policy and agree to its terms.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Build section headers with consistent style
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

  // Helper: Build section content paragraphs with consistent spacing/style
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
