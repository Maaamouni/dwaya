import 'package:flutter/material.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:dwaya_app/screens/home/home_screen.dart'; // For navigation on success
import 'package:provider/provider.dart'; // To potentially use AuthProvider later
import 'package:dwaya_app/providers/auth_provider.dart';
// Hide the conflicting AuthProvider from firebase_auth
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider; // Import FirebaseAuthException

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmailPassword() async {
    // Check form validity
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Prevent multiple clicks if already signing in
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isSigningIn) return;

    // Get email and password
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Use try-catch specifically for FirebaseAuthException
    try {
      // Call the provider method
      final success = await authProvider.signUpWithEmailPassword(
        email,
        password,
      );

      if (success) {
        // Navigation is handled by the authStateChanges listener
        print("SignUpScreen: Email/Pass sign-up initiated successfully.");
        // Check if mounted before navigating
        if (mounted) {
          // Navigate to Home and remove auth screens
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      } else {
        // This case might not be reached if exceptions are always thrown on failure
        if (mounted)
          _showErrorSnackbar(
            'Sign up failed. Please try again.',
          ); // Generic message if no exception but still failed
      }
    } on FirebaseAuthException catch (e) {
      print('SignUpScreen: FirebaseAuthException code: ${e.code}');
      String errorMessage =
          'An error occurred during sign up. Please try again.'; // Default message
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      // Use mounted check before showing snackbar
      if (mounted) _showErrorSnackbar(errorMessage);
    } catch (e) {
      // Catch any other generic errors
      print('SignUpScreen: Generic error: $e');
      if (mounted)
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  // Helper method to show error snackbar
  void _showErrorSnackbar(String message) {
    if (!mounted) return; // Extra safety check
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider for loading state
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // You can add a logo or header text here if desired
                  const Text(
                    'Create your account to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: darkGrey),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!RegExp(r"^\S+@\S+\.\S+$").hasMatch(value))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters'; // Example length check
                      // Add more password constraints if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please confirm your password';
                      if (value != _passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  ElevatedButton(
                    // Disable button if signing in
                    onPressed:
                        authProvider.isSigningIn
                            ? null
                            : _signUpWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: white,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    // Show loading indicator or text
                    child:
                        authProvider.isSigningIn
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  white,
                                ),
                              ),
                            )
                            : const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18),
                            ),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: darkGrey),
                      ),
                      TextButton(
                        onPressed:
                            () =>
                                Navigator.of(
                                  context,
                                ).pop(), // Go back to LoginScreen
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
