import 'package:flutter/material.dart';
import 'lib/screens/feedback/feedback_management_screen_new.dart';

void main() {
  runApp(const TestFeedbackApp());
}

class TestFeedbackApp extends StatelessWidget {
  const TestFeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Feedback Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const FeedbackManagementScreen(),
    );
  }
}
