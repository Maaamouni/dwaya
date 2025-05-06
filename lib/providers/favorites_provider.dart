import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  Set<String> _favoritePharmacyIds = {};
  bool _isLoading = false;
  String? _currentUserId;

  FavoritesProvider() {
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChanged);
    // Initialize with current user if already logged in
    _handleAuthStateChanged(_auth.currentUser);
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel listener when provider is disposed
    super.dispose();
  }

  // --- Getters ---
  Set<String> get favoritePharmacyIds => _favoritePharmacyIds;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUserId != null;

  bool isFavorite(String pharmacyId) {
    return _favoritePharmacyIds.contains(pharmacyId);
  }

  // --- Auth State Handling ---
  void _handleAuthStateChanged(User? user) {
    if (user != null) {
      // User logged in
      if (_currentUserId != user.uid) { // Only load if user changed
        _currentUserId = user.uid;
        _loadFavoritesFromFirestore();
      }
    } else {
      // User logged out
      _currentUserId = null;
      _favoritePharmacyIds = {}; // Clear local favorites
      _isLoading = false;
      notifyListeners(); // Notify UI about logout
    }
  }

  // --- Firestore Operations ---
  DocumentReference? get _userFavoritesDocRef {
    if (_currentUserId == null) return null;
    return _firestore.collection('users').doc(_currentUserId);
  }

  Future<void> _loadFavoritesFromFirestore() async {
    if (_userFavoritesDocRef == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final docSnapshot = await _userFavoritesDocRef!.get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        // Get the list, handle potential type issues and null
        final idsFromFirestore = data['favoritePharmacyIds'] as List?;
        if (idsFromFirestore != null) {
          // Ensure all elements are strings before converting to Set
          _favoritePharmacyIds = idsFromFirestore.map((id) => id.toString()).toSet();
        } else {
          _favoritePharmacyIds = {}; // Field doesn't exist or is null
        }
      } else {
        _favoritePharmacyIds = {}; // Document doesn't exist
      }
    } catch (e) {
      print("Error loading favorites: $e");
      _favoritePharmacyIds = {}; // Reset on error
      // Consider setting an error message state here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String pharmacyId) async {
    if (_userFavoritesDocRef == null) {
      print("Cannot toggle favorite: User not logged in.");
      // Optionally show a message to the user
      return;
    }

    final bool isCurrentlyFavorite = _favoritePharmacyIds.contains(pharmacyId);

    // Optimistically update local state
    if (isCurrentlyFavorite) {
      _favoritePharmacyIds.remove(pharmacyId);
    } else {
      _favoritePharmacyIds.add(pharmacyId);
    }
    notifyListeners();

    // Update Firestore
    try {
      if (isCurrentlyFavorite) {
        // Remove from Firestore array
        await _userFavoritesDocRef!.set({
          'favoritePharmacyIds': FieldValue.arrayRemove([pharmacyId])
        }, SetOptions(merge: true)); // Use set with merge:true to avoid overwriting other user data
      } else {
        // Add to Firestore array
        await _userFavoritesDocRef!.set({
          'favoritePharmacyIds': FieldValue.arrayUnion([pharmacyId])
        }, SetOptions(merge: true)); // Use set with merge:true
      }
    } catch (e) {
      print("Error updating favorites in Firestore: $e");
      // Revert optimistic update on error
      if (isCurrentlyFavorite) {
        _favoritePharmacyIds.add(pharmacyId); // Add back if remove failed
      } else {
        _favoritePharmacyIds.remove(pharmacyId); // Remove if add failed
      }
      notifyListeners();
      // Optionally show an error message to the user
    }
  }
} 