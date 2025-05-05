import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:dwaya_app/providers/location_provider.dart'; // Import LocationProvider
import 'package:url_launcher/url_launcher.dart';

import 'package:dwaya_app/models/pharmacy.dart';

class MapScreen extends StatefulWidget {
  // Remove userPosition parameter
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 12,
  );

  // TODO: Replace with markers based on actual pharmacy data (maybe filtered by viewport)
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('pharmacy_1'),
      position: LatLng(37.4310, -122.0840), // Example location 1
      infoWindow: InfoWindow(title: 'Silo Pharmacy', snippet: 'Open'),
    ),
    Marker(
      markerId: MarkerId('pharmacy_2'),
      position: LatLng(37.4250, -122.0860), // Example location 2
      infoWindow: InfoWindow(title: 'GoSilo Pharmacy', snippet: 'Open'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ), // Different color?
    ),
    Marker(
      markerId: MarkerId('pharmacy_3'),
      position: LatLng(37.4285, -122.0880), // Example location 3
      infoWindow: InfoWindow(title: 'Lalo Pharmacy', snippet: 'Closed'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ), // Red for closed?
    ),
  };

  // Method to get initial camera position based on provider
  CameraPosition _getInitialCameraPosition(LocationProvider locationProvider) {
    final userPosition = locationProvider.currentPosition;
    if (userPosition != null) {
      return CameraPosition(
        target: LatLng(userPosition.latitude, userPosition.longitude),
        zoom: 14.4746,
      );
    } else {
      return _kDefaultPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch LocationProvider state
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      // Using a Stack to overlay the search bar
      body: Stack(
        children: [
          // Show map only if not loading location initially
          // Or show map centered on default while loading?
          if (!locationProvider.isLoadingLocation)
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _getInitialCameraPosition(
                locationProvider,
              ),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              markers: _markers,
              myLocationEnabled: true, // Show user location dot
              myLocationButtonEnabled: true, // Show button to center on user
              padding: const EdgeInsets.only(
                top: 100.0,
                bottom: 0,
              ), // Adjust padding for overlay/buttons
            )
          else // Show loading indicator while location is fetched
            const Center(child: CircularProgressIndicator(color: primaryGreen)),
          // Search Bar Overlay
          Positioned(
            top: 50, // Adjust position as needed (consider SafeArea)
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search on map...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: darkGrey),
                  // Optional: Add clear button?
                ),
                onSubmitted: (value) {
                  // TODO: Implement map search logic (move camera, filter markers)
                  print('Map search submitted: $value');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
