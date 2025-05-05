import 'package:dwaya_app/models/pharmacy.dart';
import 'package:dwaya_app/services/places_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyProvider with ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  List<Pharmacy> _pharmacies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pharmacy> get pharmacies => _pharmacies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to fetch pharmacies based on location
  Future<void> fetchAndSetPharmacies(LatLng location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacies = await _placesService.fetchNearbyPharmacies(location);
    } catch (e) {
      print('Error in PharmacyProvider: $e');
      _errorMessage = e.toString(); // Store error message
      _pharmacies = []; // Clear pharmacies on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optional: Clear pharmacies
  void clearPharmacies() {
    _pharmacies = [];
    _errorMessage = null;
    notifyListeners();
  }
}
