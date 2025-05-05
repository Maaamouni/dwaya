import 'package:dwaya_app/providers/auth_provider.dart';
import 'package:dwaya_app/screens/home/home_screen.dart';
import 'package:dwaya_app/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider's authentication state
    final authProvider = context.watch<AuthProvider>();

    // Optionally, add a check for initial loading state if AuthProvider implements it
    // if (authProvider.isLoadingInitial) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    if (authProvider.isAuthenticated) {
      // If authenticated, show the main app screen
      return const HomeScreen();
    } else {
      // If not authenticated, show the starting point of the unauthenticated flow
      // In our case, this is the OnboardingScreen, which leads to LoginScreen
      return const OnboardingScreen();
    }
  }
}
