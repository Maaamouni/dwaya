import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:geolocator/geolocator.dart';
// import 'package:dwaya_app/services/location_service.dart'; // No longer needed here
import 'package:dwaya_app/providers/location_provider.dart'; // Import LocationProvider
import 'package:dwaya_app/widgets/app_drawer.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:dwaya_app/models/pharmacy.dart';
import 'package:dwaya_app/widgets/pharmacy_list_item.dart';
import 'package:dwaya_app/screens/home/search_results_screen.dart';
import 'package:dwaya_app/screens/home/map_screen.dart';
import 'package:dwaya_app/screens/profile/profile_screen.dart'; // Import ProfileScreen
import 'package:dwaya_app/providers/pharmacy_provider.dart'; // Import PharmacyProvider
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import LatLng

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Remove local location state and service instance
  // Position? _currentPosition;
  // bool _isLoadingLocation = true;
  // final LocationService _locationService = LocationService();

  // Remove _widgetOptions - will build dynamically based on provider state
  // late List<Widget> _widgetOptions;

  // Remove initState and related methods (_initializeWidgetOptions, _fetchInitialLocation, _showEnableLocationDialog)
  // Location fetching is now handled by LocationProvider

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_isSearching) {
      setState(() { _isSearching = false; _searchController.clear(); });
    }
    setState(() { _selectedIndex = index; });
  }

  void _toggleSearch() {
    setState(() { _isSearching = !_isSearching; if (!_isSearching) _searchController.clear(); });
  }

  void _handleSearchSubmitted(String value) {
     if (value.isNotEmpty) {
        print('Search submitted: $value');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SearchResultsScreen(searchQuery: value)),
        );
      }
  }

  // Helper method to build the body content based on selected index and provider state
  Widget _buildBody(BuildContext context) {
    // Watch LocationProvider for changes
    final locationProvider = context.watch<LocationProvider>();

    switch (_selectedIndex) {
      case 0: // Home
        return HomePageContent(); // HomePageContent will get location from provider
      case 1: // Map/Search
        return MapScreen(); // MapScreen will get location from provider
      case 2: // Analytics
        return const Center(child: Text('Analytics Page'));
      case 3: // History
        return const Center(child: Text('History Page'));
      case 4: // Profile
        return const ProfileScreen(); // Use the new ProfileScreen
      default:
        return HomePageContent(); // Default to Home
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: white,
        elevation: 1,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search pharmacies...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: darkGrey),
                ),
                onSubmitted: _handleSearchSubmitted,
              )
            : Padding(
                 padding: const EdgeInsets.only(left: 8.0),
                 child: Image.asset('assets/images/logo.png', height: 28),
              ),
         // Dynamically set actions based on search state
        actions: _isSearching
            ? [
                // Close search button
                IconButton(
                  icon: const Icon(Icons.close, color: black),
                  onPressed: _toggleSearch,
                ),
              ]
            : [
                // Search icon button
                IconButton(
                  icon: const Icon(Icons.search, color: black),
                  onPressed: _toggleSearch,
                ),
                 // Optional: Keep other actions like notifications if needed
                // IconButton(
                //   icon: const Icon(Icons.notifications_none, color: black),
                //   onPressed: () {}, 
                // ),
              ],
      ),
      body: _buildBody(context), // Use the helper method to build body
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryGreen,
        unselectedItemColor: darkGrey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- Update HomePageContent --- 

class HomePageContent extends StatefulWidget { // Change to StatefulWidget
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> { // Create State
  bool _initialFetchDone = false; // Flag to prevent multiple fetches

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPharmaciesIfNeeded(); // Call fetch logic here
  }

  void _fetchPharmaciesIfNeeded() {
    // Get providers without listening here (just reading)
    final locationProvider = context.read<LocationProvider>();
    final pharmacyProvider = context.read<PharmacyProvider>();
    final currentLocation = locationProvider.currentPosition;

    // Fetch only if location is available, not loading, and fetch hasn't been done yet
    if (currentLocation != null && !locationProvider.isLoadingLocation && !_initialFetchDone) {
      print('HomePageContent: Location available, fetching pharmacies...');
      pharmacyProvider.fetchAndSetPharmacies(
        LatLng(currentLocation.latitude, currentLocation.longitude)
      );
      setState(() { _initialFetchDone = true; }); // Mark fetch as done
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch LocationProvider state
    final locationProvider = context.watch<LocationProvider>();
    // Watch PharmacyProvider state
    final pharmacyProvider = context.watch<PharmacyProvider>();

    final locationIsLoading = locationProvider.isLoadingLocation;
    final currentPosition = locationProvider.currentPosition;
    final serviceDisabled = locationProvider.locationServiceInitiallyDisabled;
    final permissionDenied = locationProvider.locationPermissionDenied;

    // Get pharmacy state
    final pharmacyIsLoading = pharmacyProvider.isLoading;
    final pharmacies = pharmacyProvider.pharmacies;
    final pharmacyError = pharmacyProvider.errorMessage;

    // Check location status first (as before)
    if (locationIsLoading && !_initialFetchDone) {
        return const Center(child: Text('Getting location...')); // More specific text
    }
    if (serviceDisabled) {
       return _buildLocationMessage(
          context,
          'Location services are disabled. Please enable them in your device settings to find nearby pharmacies.',
          'Open Location Settings',
          () => locationProvider.openLocationSettings()
       );
    }
    if (permissionDenied) {
       return _buildLocationMessage(
          context,
          'Location permission is required to find nearby pharmacies. Please grant permission.',
          'Request Permission',
          () => locationProvider.requestPermission()
       );
    }

    // Now check pharmacy fetch status
    if (pharmacyIsLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryGreen));
    }

    if (pharmacyError != null) {
        return Center(
           child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error loading pharmacies: \n$pharmacyError', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
           )
        ); // Show error from provider
    }

    if (pharmacies.isEmpty && _initialFetchDone) {
       // Ensure location wasn't loading before showing "No pharmacies"
       return const Center(child: Text('No pharmacies found nearby.'));
    }

    // --- Build the main content --- 

    // TODO: Fetch pharmacies based on currentPosition (or show all if null?)
    // Replace dummy data with fetched data later
    // final List<Pharmacy> _pharmacies = [...]; // REMOVE DUMMY DATA

    return Column(
      children: [
        // Refined Header (e.g., a promotional banner)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: primaryGreen.withOpacity(0.1), // Lighter green background
          width: double.infinity,
          child: const Row(
            children: [
              Icon(Icons.campaign_outlined, color: primaryGreen),
              SizedBox(width: 10),
              Expanded(
                 child: Text(
                    'Special offers available now! Check details.', // Example text
                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w500),
                 ),
              ),
            ],
          ),
        ),
        // Pharmacy List Area
        Expanded(
          // Pass the fetched pharmacies list to the builder method
          child: _buildPharmacyList(context, pharmacies),
        ),
      ],
    );
  }

  // Helper for location status messages
  Widget _buildLocationMessage(BuildContext context, String message, String buttonText, VoidCallback onPressed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column( 
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: darkGrey, fontSize: 15),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: Text(buttonText),
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      );
  }

  // Updated helper method using provider state
  // Removed unused parameters (isLoading, position, serviceDisabled, permissionDenied)
  Widget _buildPharmacyList(BuildContext context, List<Pharmacy> pharmacies) {
    // Loading, error, and empty states are handled in the build method now
    return RefreshIndicator(
        onRefresh: () async {
           // Trigger a new fetch when user pulls down
           final locationProvider = context.read<LocationProvider>();
           final currentLocation = locationProvider.currentPosition;
           if (currentLocation != null) {
              await context.read<PharmacyProvider>().fetchAndSetPharmacies(
                 LatLng(currentLocation.latitude, currentLocation.longitude)
              );
           }
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure list is always scrollable for RefreshIndicator
          itemCount: pharmacies.length,
          itemBuilder: (context, index) {
            return PharmacyListItem(pharmacy: pharmacies[index]);
          },
        ),
      );
  }
}
