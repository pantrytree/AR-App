import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // Hardcoded app information
  final String _appName = 'Roomantic';
  final String _appVersion = '0.0.1';
  final String _buildNumber = '#0001';
  final String _releaseDate = '2025';

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Application',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // App Icon and Name
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chair,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Interior Design AR App',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),

            const SizedBox(height: 40),

            // App Information
            _buildInfoCard(
              title: 'Version Information',
              children: [
                _buildInfoRow('App Name', _appName),
                _buildInfoRow('Version', '$_appVersion (Build $_buildNumber)'),
                _buildInfoRow('Release Date', _releaseDate),
              ],
            ),

            const SizedBox(height: 20),

            _buildInfoCard(
              title: 'Developer Information',
              children: [
                _buildInfoRow('Developed By', 'S10 Technologies'),
                _buildInfoRow('Contact', 's10tech@gmail.com'),
                _buildInfoRow('Website', 'www.roomantic.com'),
              ],
            ),

            const SizedBox(height: 20),

            _buildInfoCard(
              title: 'App Description',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Roomantics is a one of a kind AR android app that introduces AR functionality in android. Roomantics is for our Roomies.',
                    style: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildInfoCard(
              title: 'Features',
              children: [
                _buildFeatureItem('AR Furniture Placement'),
                _buildFeatureItem('Project Management'),
                _buildFeatureItem('Furniture Catalogue'),
                _buildFeatureItem('Dark/Light Theme'),
                _buildFeatureItem('Real-time Previews'),
              ],
            ),

            const SizedBox(height: 20),

            _buildInfoCard(
              title: 'Legal',
              children: [
                ListTile(
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.getSecondaryTextColor(context),
                    size: 16,
                  ),
                  onTap: () {
                    _showPlaceholderDialog(context, 'Privacy Policy');
                  },
                ),
                ListTile(
                  title: Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.getSecondaryTextColor(context),
                    size: 16,
                  ),
                  onTap: () {
                    _showPlaceholderDialog(context, 'Terms of Service');
                  },
                ),
                ListTile(
                  title: Text(
                    'Open Source Licenses',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.getSecondaryTextColor(context),
                    size: 16,
                  ),
                  onTap: () {
                    _showPlaceholderDialog(context, 'Open Source Licenses');
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Copyright
            Text(
              '© $_releaseDate Roomantic. All rights reserved.',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.getPrimaryColor(context),
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              color: AppColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This $title page is coming soon. It will be available in a future update.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.getPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}