import 'package:flutter/material.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:dwaya_app/providers/auth_provider.dart'; // Import AuthProvider
import 'package:dwaya_app/screens/auth/login_screen.dart'; // Import Login for navigation

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Helper method to handle logout
  Future<void> _handleLogout(BuildContext context) async {
    // Use context.read for one-off action
    await context.read<AuthProvider>().signOut();
    // After logout, navigate back to Login screen and remove all routes behind it
    if (context.mounted) {
      // Check context validity
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false, // Remove all routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                ), // Logo in drawer header
                const SizedBox(height: 10),
                const Text(
                  'DOUAYA', // Updated App Name
                  style: TextStyle(color: white, fontSize: 20),
                ),
                // Optionally show user email if available
                Consumer<AuthProvider>(
                  // Use Consumer to get user info
                  builder: (context, auth, child) {
                    return Text(
                      auth.currentUser?.email ?? 'Quick pharmacy access',
                      style: const TextStyle(color: white, fontSize: 14),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: darkGrey),
            title: const Text('Home'),
            onTap: () {
              // TODO: Navigate to Home (if not already there)
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: darkGrey),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to Settings Screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: darkGrey),
            title: const Text('About'),
            onTap: () {
              // TODO: Show About Dialog or Screen
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: darkGrey),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context), // Call logout method
          ),
          // Add more drawer items as needed
        ],
      ),
    );
  }
}
