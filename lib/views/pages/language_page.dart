import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'English';

  // List of supported languages, each with its code, English name, and native name
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'af', 'name': 'Afrikaans', 'native': 'Afrikaans'},
    {'code': 'zu', 'name': 'Zulu', 'native': 'isiZulu'},
    {'code': 'xh', 'name': 'Xhosa', 'native': 'isiXhosa'},
  ];

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
          'Language Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = _selectedLanguage == language['name'];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppColors.getCardBackground(context),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    language['code']!.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryColor(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              title: Text(
                language['name']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(context),
                ),
              ),
              subtitle: Text(
                language['native']!,
                style: TextStyle(
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              trailing: isSelected
                  ? Icon(
                Icons.check_circle,
                color: AppColors.getPrimaryColor(context),
              )
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = language['name']!;
                });
                // TODO: Save language preference and update app locale
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to ${language['name']}'),
                    backgroundColor: AppColors.success,
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
