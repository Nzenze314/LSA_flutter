import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:counter/src/features/auth/login_page.dart'; // Import the login page

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final List<PageModel> pages = [
    PageModel(
      color: const Color(0xFF0097A7),
      imageAssetPath: 'assets/images/onbording1.png',
      title: 'Welcome to Chatbot',
      body: 'Your personal AI assistant for all your needs.',
      doAnimateImage: true,
    ),
    PageModel(
      color: const Color(0xFF536DFE),
      imageAssetPath: 'assets/images/onbording1.png',
      title: 'Smart Conversations',
      body: 'Engage in intelligent conversations and get instant answers.',
      doAnimateImage: true,
    ),
    PageModel(
      color: const Color(0xFF9C27B0),
      imageAssetPath: 'assets/images/onbording1.png',
      title: 'Personalized Experience',
      body: 'Customize your chat experience and save your preferences.',
      doAnimateImage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        finishCallback: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
    );
  }
}
