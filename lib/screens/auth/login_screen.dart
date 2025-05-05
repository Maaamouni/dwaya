import 'package:dwaya_app/screens/auth/sign_up_screen.dart';
import 'package:dwaya_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:dwaya_app/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isSigningIn) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final success = await authProvider.signInWithEmailPassword(
        email,
        password,
      );
      if (success) {
        print("LoginScreen: Email/Pass sign-in initiated successfully.");
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) _showErrorSnackbar('Login failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      print('LoginScreen: FirebaseAuthException code: ${e.code}');
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many login attempts. Please try again later.';
      }
      if (mounted) _showErrorSnackbar(errorMessage);
    } catch (e) {
      print('LoginScreen: Generic error: $e');
      if (mounted)
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    bool success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      print("LoginScreen: Google Sign-In successful, navigating home.");
      _navigateToHome();
    } else if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  void _forgotPassword() {
    print('Forgot Password tapped');
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isSigningIn = authProvider.isSigningIn;

    return Scaffold(
      backgroundColor: white,
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
                  Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: darkGrey),
                  ),
                  const SizedBox(height: 30),

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
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot Password?'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                        authProvider.isSigningIn
                            ? null
                            : _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: white,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                  ),
                  const SizedBox(height: 25),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR', style: TextStyle(color: darkGrey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed:
                        isSigningIn ? null : () => _signInWithGoogle(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: black,
                      backgroundColor: white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: mediumGrey),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    icon: isSigningIn
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.redAccent,
                              ),
                            ),
                          )
                        : const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                    label: Text(
                      isSigningIn ? 'Signing In...' : 'Continue with Google',
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: darkGrey),
                      ),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: const Text(
                          'Sign Up',
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
