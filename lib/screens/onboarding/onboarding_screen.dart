import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dwaya_app/utils/colors.dart';
// Import login screen later for navigation
import 'package:dwaya_app/screens/auth/login_screen.dart';
import 'package:dwaya_app/services/location_service.dart'; // Import the service
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  final LocationService _locationService = LocationService();
  bool _isLoading = false; // Add loading state for finish/skip action

  // Method to navigate to the next page
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  // Method to handle final navigation (Skip or Get Started)
  void _finishOnboarding() async {
    // Prevent multiple clicks while processing
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Set loading state
    });

    print('Onboarding finished/skipped. Requesting location permission...');
    bool permissionGranted = false; // Default to false
    try {
      // Only request permission if NOT on web
      if (!kIsWeb) {
         permissionGranted = await _locationService.requestLocationPermission();
      } else {
        print('Skipping location permission request on web.');
        // Optionally, you could try HTML5 geolocation here if needed,
        // but permission_handler doesn't support it directly.
      }
    } catch (e) {
       print("Error requesting location permission: $e");
       // Handle error appropriately, maybe show a message
    }

    if (mounted) { // Check before proceeding after await
        if (permissionGranted) {
          print('Location permission granted after onboarding.');
        } else {
          print('Location permission denied after onboarding.');
          // Consider showing a message explaining the need for location
        }

        print('Navigating to LoginScreen...');
        // Navigate regardless of permission (as per current logic)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        // No need to set _isLoading = false as we are navigating away
    } else {
      // Widget was disposed before navigation could happen
      setState(() {
         _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                // Update _isLastPage based on the index (assuming 3 pages: 0, 1, 2)
                _isLastPage = index == 2;
              });
            },
            children: const [
              OnboardingPageWidget(
                imagePlaceholderColor: Colors.blueGrey,
                title: 'Find pharmacy near you',
                description: "It's easy to find pharmacy that is near to your location. With just one tap.",
              ),
              OnboardingPageWidget(
                imagePlaceholderColor: Colors.teal,
                title: 'Search with our database',
                description: "It's easy to find pharmacy that is near to your location. With just one tap.",
              ),
              OnboardingPageWidget(
                imagePlaceholderColor: Colors.indigo,
                title: 'Get delivery on your door',
                description: "It's easy to find pharmacy that is near to your location. With just one tap.",
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: primaryGreen,
                dotColor: mediumGrey,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  // Disable skip button if loading
                  onPressed: _isLoading || _isLastPage ? null : _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      // Hide skip if last page OR if loading
                      color: _isLastPage || _isLoading ? Colors.transparent : darkGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Conditional Button: Next or Get Started
                ElevatedButton(
                  // Use appropriate function, disable if loading
                  onPressed: _isLoading ? null : (_isLastPage ? _finishOnboarding : _nextPage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Show loading indicator or text
                  child: _isLoading && _isLastPage 
                      ? const SizedBox(
                          height: 18, 
                          width: 18, 
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(white))
                        )
                      : Text(
                          _isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widget for each onboarding page
class OnboardingPageWidget extends StatelessWidget {
  final Color imagePlaceholderColor;
  final String title;
  final String description;

  const OnboardingPageWidget({
    super.key,
    required this.imagePlaceholderColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for Image
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imagePlaceholderColor, // Use placeholder color
              borderRadius: BorderRadius.circular(12),
            ),
            // TODO: Replace with actual Image widget when assets are available
             child: const Center(child: Text('Image Placeholder', style: TextStyle(color: white))),          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: darkGrey,
            ),
          ),
          const SizedBox(height: 100), // Space for indicator and buttons
        ],
      ),
    );
  }
} 