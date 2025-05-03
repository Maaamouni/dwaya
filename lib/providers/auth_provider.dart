import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Keep GoogleSignIn initialization for the sign-in flow itself
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // TODO: Add your Web Client ID here for web support (if needed)
  clientId: "321771410537-6hljqq0mmtb85vthhullk6q73c3acj1c.apps.googleusercontent.com",
);

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  User? _currentUser; // Changed to Firebase User
  bool _isSigningIn = false;

  User? get currentUser => _currentUser; // Changed getter type
  bool get isSigningIn => _isSigningIn;
  // Check Firebase user for authentication status
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      print("AuthProvider: Firebase User changed: ${user?.uid} (${user?.email})");
      _currentUser = user;
      notifyListeners(); // Notify listeners about the change
    });
  }

  Future<bool> signInWithGoogle() async {
    if (_isSigningIn) return false;
    _isSigningIn = true;
    notifyListeners();

    bool success = false;
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential for Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        // No need to manually set _currentUser, authStateChanges listener handles it
        if (userCredential.user != null) {
           print("AuthProvider: Firebase Sign-In via Google successful: ${userCredential.user?.uid}");
           success = true;
        } else {
           print('AuthProvider: Firebase Sign-In via Google failed (user null).');
        }
      } else {
        print('AuthProvider: Google Sign-In cancelled by user.');
      }
    } catch (error) {
      print("AuthProvider: Error during Google Sign-In or Firebase credential sign-in: $error");
      // Consider showing a user-friendly error message
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> signOut() async {
    try {
       // Sign out from Firebase
       await _auth.signOut();
       // Also sign out from Google
       await _googleSignIn.signOut();
       print("AuthProvider: User signed out from Firebase and Google.");
       // No need to manually set _currentUser to null, authStateChanges listener handles it
       // notifyListeners(); // Listener handles notification
    } catch (error) {
       print("AuthProvider: Error signing out: $error");
       // Consider showing a user-friendly error message
    }
  }

  // --- Placeholder methods for other auth types ---

  Future<bool> signInWithEmailPassword(String email, String password) async {
    if (_isSigningIn) return false;
    _isSigningIn = true;
    notifyListeners();
    bool success = false;

    print('AuthProvider: Attempting Email/Pass Sign-In: $email');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Auth state listener will update _currentUser and notify
      print('AuthProvider: Email/Pass Sign-In successful.');
      success = true;
    } on FirebaseAuthException catch (e) {
      print('AuthProvider: Firebase Auth Error (Sign In): ${e.code} - ${e.message}');
      // TODO: Provide user feedback based on e.code (e.g., 'invalid-credential', 'user-disabled')
    } catch (e) {
      print('AuthProvider: Generic Sign In Error: $e');
      // TODO: Provide user feedback
    } finally {
       _isSigningIn = false;
       notifyListeners();
    }
    return success;
  }

  Future<bool> signUpWithEmailPassword(String email, String password) async {
    if (_isSigningIn) return false;
    _isSigningIn = true;
    notifyListeners();
    bool success = false;

    print('AuthProvider: Attempting Email/Pass Sign-Up: $email');
     try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Auth state listener will update _currentUser and notify
      print('AuthProvider: Email/Pass Sign-Up successful.');
      success = true;
    } on FirebaseAuthException catch (e) {
       print('AuthProvider: Firebase Auth Error (Sign Up): ${e.code} - ${e.message}');
       // TODO: Provide user feedback based on e.code (e.g., 'weak-password', 'email-already-in-use')
    } catch (e) {
       print('AuthProvider: Generic Sign Up Error: $e');
       // TODO: Provide user feedback
    } finally {
       _isSigningIn = false;
       notifyListeners();
    }
    return success;
  }

  // TODO: Add methods for Phone/OTP Auth using FirebaseAuth if implementing that flow
  // e.g., verifyPhoneNumber, signInWithPhoneNumberCredential

} 