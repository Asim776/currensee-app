import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "q": "What is CurrenSee?",
      "a": "CurrenSee is a currency conversion app that allows users to convert currencies in real-time with ease.",
    },
    {
      "q": "How do I convert currencies?",
      "a": "Select the 'From' and 'To' currencies, enter the amount, and tap 'Convert'.",
    },
    {
      "q": "Is the currency exchange rate updated in real-time?",
      "a": "Yes, CurrenSee fetches real-time exchange rates.",
    },
    {
      "q": "Can I use CurrenSee offline?",
      "a": "You can view previously fetched rates offline, but live updates need internet.",
    },
    {
      "q": "Does CurrenSee support all currencies?",
      "a": "Yes, major and minor global currencies are supported.",
    },
    {
      "q": "How can I change the app's default currency?",
      "a": "You can update this in the settings menu.",
    },
    {
      "q": "Is CurrenSee free to use?",
      "a": "Yes, it's free. Premium features may come in future updates.",
    },
    {
      "q": "How do I report a problem or give feedback?",
      "a": "Use the 'Help & Support' section from the app menu.",
    },
    {
      "q": "How do I log out of my account?",
      "a": "Go to menu → Logout → Confirm.",
    },
    {
      "q": "Can I save my favorite currency pairs?",
      "a": "Yes, you can mark and access them easily.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "FAQs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQCard(faqs[index]["q"]!, faqs[index]["a"]!);
        },
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4facfe), Color(0xff00f2fe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
