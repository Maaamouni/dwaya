import 'dart:convert';
import 'package:dwaya_app/models/pharmacy.dart'; // Adjust if model changes
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// REMOVED: const String _apiKey = "...";

class PlacesService {
  // REMOVED: No longer need API key in the frontend service
  // final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Fetches nearby pharmacies by calling a backend proxy.
  ///
  /// Requires user's current [location] and a [radius] in meters.
  Future<List<Pharmacy>> fetchNearbyPharmacies(
    LatLng location, {
    int radius = 5000,
  }) async {
    // REMOVED: API Key check no longer needed here
    // if (_apiKey.isEmpty) {
    //   print('Error: GOOGLE_MAPS_API_KEY not found in .env file.');
    //   throw Exception('API key not configured.');
    // }

    // Define the URL for your backend proxy endpoint
    // TODO: Replace 'YOUR_PROXY_ENDPOINT_HERE' with your actual proxy URL
    const String proxyBaseUrl = String.fromEnvironment(
      'PROXY_BASE_URL',
      defaultValue:
          'https://workers-playground-round-sea-78ec.hduvehjdvuzv.workers.dev', // Updated with Apps Script URL
    );
    final url = Uri.parse(
      proxyBaseUrl,
    ); // Use the base URL directly as it includes the path

    try {
      // Send data to the proxy via POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'radius': radius,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming the proxy returns data in a 'results' list
        // Adjust this based on your actual proxy response structure
        if (data['results'] != null && data['results'] is List) {
          final List results = data['results'];
          print('Proxy returned ${results.length} results.');

          // Map proxy results to Pharmacy objects
          // TODO: Verify and adjust this mapping based on the proxy response format
          return results.map((place) {
            // Assuming proxy returns data similar to Google Places format
            final lat = place['latitude'] as double? ?? 0.0;
            final lng = place['longitude'] as double? ?? 0.0;
            final isOpenNow =
                place['isOpen'] as bool?; // Adjust field name if needed

            return Pharmacy(
              id: place['id'] as String? ?? '', // Adjust field name if needed
              name: place['name'] as String? ?? 'Unknown Pharmacy',
              address: place['address'] as String? ?? 'Address not available',
              latitude: lat,
              longitude: lng,
              distance:
                  place['distance'] as String? ??
                  'N/A', // Proxy might calculate distance
              isOpen: isOpenNow ?? false,
              imageUrl:
                  place['imageUrl'] as String? ??
                  '', // Proxy might provide image URL
            );
          }).toList();
        } else {
          // Handle potential errors reported by the proxy
          final errorMessage = data['error'] ?? 'Unknown error from proxy';
          print('Proxy Error: $errorMessage');
          throw Exception('Proxy Error: $errorMessage');
        }
      } else {
        print(
          'HTTP Error contacting proxy: ${response.statusCode} ${response.reasonPhrase}',
        );
        print('Response body: ${response.body}'); // Log body for debugging
        throw Exception(
          'Failed to load pharmacies from proxy: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching pharmacies via proxy: $e');
      // Consider more specific error handling (e.g., network errors)
      throw Exception('Failed to fetch pharmacies via proxy: $e');
    }
  }

  // TODO: Add method to fetch place details (for address, photos, etc.) using place_id if needed
  // This might also need to go through the proxy
  // Future<PlaceDetails> fetchPlaceDetails(String placeId) async { ... }
}
