import 'package:flutter/material.dart';
import 'package:dwaya_app/models/pharmacy.dart';
import 'package:dwaya_app/utils/colors.dart';

class PharmacyDetailScreen extends StatelessWidget {
  final Pharmacy pharmacy; // Accept pharmacy data

  const PharmacyDetailScreen({super.key, required this.pharmacy});

  // Add the same helper function here (or move to a utils file)
  String _formatDistance(double? meters) {
    if (meters == null) {
      return 'N/A';
    }
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m away';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, // Height of the image area
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: primaryGreen, // Background when collapsed
            leading: IconButton(
              icon: const CircleAvatar(
                // White background for visibility on image
                backgroundColor: Colors.white70,
                child: Icon(Icons.arrow_back, color: black),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Keep title centered when collapsed
              title: Text(
                pharmacy.name,
                style: const TextStyle(color: white, fontSize: 16.0),
              ),
              background: pharmacy.imageUrl.isNotEmpty
                  ? Image.network(
                      pharmacy.imageUrl,
                      fit: BoxFit.cover,
                      // Optional: Add error/loading builders if needed
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: mediumGrey,
                        child: const Center(
                          child: Icon(Icons.storefront, size: 100, color: lightGrey),
                        ),
                      ),
                    )
                  : Container(
                      // Placeholder for the pharmacy image if URL is empty
                      color: mediumGrey,
                      child: const Center(
                        child: Icon(Icons.storefront, size: 100, color: lightGrey),
                      ),
                    ),
              stretchModes: const [StretchMode.zoomBackground],
            ),
          ),
          // Content below the app bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info section (Reusing parts of list item logic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pharmacy
                                  .name, // Repeated from AppBar, maybe style differently
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pharmacy.address} (${_formatDistance(pharmacy.distance)})', // Use formatter
                              style: const TextStyle(
                                fontSize: 14,
                                color: darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              pharmacy.isOpen
                                  ? primaryGreen.withAlpha(26)
                                  : Colors.red.withAlpha(26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pharmacy.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: pharmacy.isOpen ? primaryGreen : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Working Time section
                  const Text(
                    'Working Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: darkGrey),
                      SizedBox(width: 8),
                      // TODO: Replace with actual working hours data
                      Expanded(
                        child: Text(
                          'Mon - Fri: 09:00 AM - 6:00 PM',
                          style: TextStyle(fontSize: 14, color: darkGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: darkGrey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sat - Sun: Closed',
                          style: TextStyle(fontSize: 14, color: darkGrey),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Details Section
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // TODO: Replace with actual details data
                  const Text(
                    'This pharmacy offers a wide range of prescription and over-the-counter medications. Pharmacist consultation available. Delivery services may be offered.',
                    style: TextStyle(
                      fontSize: 14,
                      color: darkGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20), // Add some bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
