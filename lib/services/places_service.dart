import 'dart:convert';
import 'package:dwaya_app/models/pharmacy.dart'; // Adjust if model changes
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// TODO: Store API key securely, not directly in code (e.g., use flutter_dotenv)
const String _apiKey = "AIzaSyA0dHOOzqPjb5flFOH4uZYTi4jQMd91O0o";

class PlacesService {

  /// Fetches nearby pharmacies using the Google Places API.
  ///
  /// Requires user's current [location] and a [radius] in meters.
  Future<List<Pharmacy>> fetchNearbyPharmacies(LatLng location, {int radius = 5000}) async {
    // Construct the API request URL
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&type=pharmacy&key=$_apiKey'
    );

    print('Places API Request: $url'); // For debugging

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List results = data['results'];
          print('Places API found ${results.length} results.');

          // Map API results to Pharmacy objects
          // TODO: Refine this mapping based on the final Pharmacy model
          return results.map((place) {
             final geometry = place['geometry']?['location'];
             final lat = geometry?['lat'] as double? ?? 0.0;
             final lng = geometry?['lng'] as double? ?? 0.0;
             final isOpenNow = place['opening_hours']?['open_now'] as bool?;

             // Note: Distance isn't directly provided by Nearby Search.
             // We'd need to calculate it or use a different API/approach.

             return Pharmacy(
               id: place['place_id'] as String? ?? '', // Use place_id
               name: place['name'] as String? ?? 'Unknown Pharmacy',
               address: place['vicinity'] as String? ?? 'Address not available', // Vicinity is often shorter than formatted_address
               latitude: lat, // Populate latitude
               longitude: lng, // Populate longitude
               distance: 'N/A', // Placeholder for distance
               isOpen: isOpenNow ?? false,
               imageUrl: '', // Fetching photos requires another API call using photo_reference
             );
          }).toList();

        } else {
          print('Places API Error: ${data['status']} - ${data['error_message']}');
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load pharmacies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pharmacies: $e');
      throw Exception('Failed to fetch pharmacies: $e');
    }
  }

   // TODO: Add method to fetch place details (for address, photos, etc.) using place_id if needed
   // Future<PlaceDetails> fetchPlaceDetails(String placeId) async { ... }
} 