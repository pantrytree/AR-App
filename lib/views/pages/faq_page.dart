import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> faqs = const [
    {'question': 'How do I reset my password?', 'answer': 'Go to settings > account > reset password.'},
    {'question': 'How to save a design?', 'answer': 'Tap the save icon on your design screen.'},
    {'question': 'Can I share designs?', 'answer': 'Yes! Tap the share button and select a method.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(
              faq['question']!,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  faq['answer']!,
                  style: GoogleFonts.inter(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
