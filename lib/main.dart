import 'package:flutter/material.dart';
import 'package:counter/src/features/onboarding/onboarding_page.dart'; // Assuming onboarding is the initial route
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:counter/src/utils/constants.dart';
import 'package:counter/src/features/chat/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jxwljzluygmbogwajkgp.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4d2xqemx1eWdtYm9nd2Fqa2dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NjA1OTUsImV4cCI6MjA2OTUzNjU5NX0.1M7baVwaKrsElXfVN2KQaB4y4qlbnLu4KuPvGwgBTaU', // Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingPage(), // Set the initial route
    );
  }
}
