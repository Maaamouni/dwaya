import 'dart:async';
import 'package:flutter/material.dart';
// No longer need Provider or AuthProvider here for navigation check
// import 'package:provider/provider.dart';
// import 'package:dwaya_app/providers/auth_provider.dart';
import 'package:dwaya_app/utils/colors.dart';
// No longer need these direct imports
// import 'package:dwaya_app/screens/onboarding/onboarding_screen.dart';
// import 'package:dwaya_app/screens/home/home_screen.dart';
import 'package:dwaya_app/widgets/auth_wrapper.dart'; // Import the AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWrapper(); // Call the updated navigation method
  }

  Future<void> _navigateToWrapper() async {
     // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) { // Check if mounted after delay
      print("SplashScreen: Delay finished, navigating to AuthWrapper.");
      // Navigate to the AuthWrapper which will handle the auth check
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add the actual logo asset
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Image.asset for the logo
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            const SizedBox(height: 10), // Adjust spacing
            const Text(
              'Quick pharmacy',
              style: TextStyle(
                fontSize: 16,
                color: darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 