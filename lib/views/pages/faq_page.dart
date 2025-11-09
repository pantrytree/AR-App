import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// FAQPage is a stateful widget that displays frequently asked questions
class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  // Constant list of FAQ categories with their questions and answers
  final List<Map<String, dynamic>> faqCategories = const [
    {
      'category': 'Projects & Designs',
      'faqs': [
        {'question': 'How do I save my project?', 'answer': 'Tap the save icon on your project screen.'},
        {'question': 'Can I export designs to PDF?', 'answer': 'Yes, use the export option in the menu.'},
        {'question': 'How many projects can I create?', 'answer': 'You can create up to 10 projects on the free plan.'},
        {'question': 'How do I recover a deleted project?', 'answer': 'Check the trash folder in settings within 30 days.'},
        {'question': 'Are there tutorials available?', 'answer': 'Yes, check the guides section for video tutorials.'},
      ],
    },
    {
      'category': 'App & Platform',
      'faqs': [
        {'question': 'Is the app available on Android and iOS?', 'answer': 'Yes, available on both platforms.'},
        {'question': 'What should I do if the app crashes?', 'answer': 'Restart the app or contact support with details.'},
      ],
    },
    {
      'category': 'Billing & Subscriptions',
      'faqs': [
        {'question': 'What payment methods are accepted?', 'answer': 'We accept credit cards, PayPal, and bank transfers.'},
        {'question': 'How do I cancel my subscription?', 'answer': 'Go to settings > subscriptions > cancel plan.'},
        {'question': 'Can I upgrade my plan?', 'answer': 'Yes, visit the upgrade section in settings.'},
      ],
    },
    {
      'category': 'Support & Security',
      'faqs': [
        {'question': 'How do I contact support?', 'answer': 'Use the help section or email support@yourapp.com.'},
        {'question': 'Is my data secure?', 'answer': 'Yes, we use encryption to protect your data.'},
      ],
    },
  ];

  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  
  // Filtered list of categories based on search query
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    // Initialize filtered categories with all categories
    _filteredCategories = List.from(faqCategories);
    
    // Add listener to search controller to filter FAQs when text changes
    _searchController.addListener(_filterFAQs);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  // Method to filter FAQs based on search query
  void _filterFAQs() {
    final query = _searchController.text.toLowerCase();
    
    // If search query is empty, show all categories
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = List.from(faqCategories);
      });
      return;
    }

    // Filter categories and FAQs based on search query
    final filtered = <Map<String, dynamic>>[];
    for (final category in faqCategories) {
      // Filter FAQs within this category that match the search query
      final filteredFAQs = (category['faqs'] as List<Map<String, String>>).where((faq) {
        return faq['question']!.toLowerCase().contains(query) || 
               faq['answer']!.toLowerCase().contains(query);
      }).toList();

      // Only add category if it has matching FAQs
      if (filteredFAQs.isNotEmpty) {
        filtered.add({
          'category': category['category'],
          'faqs': filteredFAQs,
        });
      }
    }

    // Update UI with filtered results
    setState(() {
      _filteredCategories = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
        title: Text(
          'FAQ',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF0F4FF), // Light purple background
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8), // Small top padding after AppBar
            
            // Search text field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: GoogleFonts.inter(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Remove border
                ),
                filled: true,
                fillColor: Colors.white, // White background for search field
              ),
            ),
            
            const SizedBox(height: 16), // Spacing between search and list
            
            // Expand to take available space for the FAQ list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCategories.length,
                itemBuilder: (context, catIndex) {
                  final category = _filteredCategories[catIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category title
                      Text(
                        category['category'],
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12), // Spacing after category title
                      
                      // List of FAQ items for this category
                      ListView.builder(
                        shrinkWrap: true, // Important for nested ListView
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested list
                        itemCount: (category['faqs'] as List).length,
                        itemBuilder: (context, index) {
                          final faq = category['faqs'][index] as Map<String, String>;
                          return FAQItem(
                            question: faq['question']!,
                            answer: faq['answer']!,
                          );
                        },
                      ),
                      const SizedBox(height: 24), // Spacing between categories
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16), // Spacing before contact support button
            
            // Contact support button
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to contact support or open email
                },
                child: Text(
                  'Still need help? Contact Support',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Individual FAQ item widget that can expand/collapse
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHelpful = false; // Track if user found this helpful
  bool _isNotHelpful = false; // Track if user didn't find this helpful

  @override
  void initState() {
    super.initState();
    // Animation controller for the expand/collapse arrow rotation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 0.0, // Start collapsed
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to handle helpful/not helpful feedback
  void _toggleHelpful(bool helpful) {
    setState(() {
      _isHelpful = helpful;
      _isNotHelpful = !helpful;
    });
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(helpful ? 'Thanks! Glad it helped.' : 'Sorry to hear that. We\'ll improve it.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent, // Remove default divider
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              widget.question,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Animated arrow that rotates when expanded/collapsed
            trailing: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
              child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 24),
            ),
            onExpansionChanged: (expanded) {
              // Animate arrow when expanding/collapsing
              if (expanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            collapsedBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FAQ answer text
                    Text(
                      widget.answer,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12), // Spacing before feedback buttons
                    
                    // Helpful/Not helpful feedback buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _toggleHelpful(true),
                            icon: Icon(
                              _isHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                              color: _isHelpful ? Colors.green : Colors.black54,
                            ),
                            label: Text(
                              'Helpful',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _isHelpful ? Colors.green : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Spacing between buttons
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _toggleHelpful(false),
                            icon: Icon(
                              _isNotHelpful ? Icons.thumb_down : Icons.thumb_down_outlined,
                              color: _isNotHelpful ? Colors.red : Colors.black54,
                            ),
                            label: Text(
                              'Not Helpful',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _isNotHelpful ? Colors.red : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
