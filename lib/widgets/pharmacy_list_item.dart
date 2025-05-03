import 'package:flutter/material.dart';
import 'package:dwaya_app/models/pharmacy.dart';
import 'package:dwaya_app/utils/colors.dart';
import 'package:dwaya_app/screens/home/pharmacy_detail_screen.dart';

class PharmacyListItem extends StatelessWidget {
  final Pharmacy pharmacy;

  const PharmacyListItem({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PharmacyDetailScreen(pharmacy: pharmacy),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Placeholder Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(8.0),
                  // TODO: Replace with actual image loading (Image.network or Image.asset)
                  // image: DecorationImage(image: NetworkImage(pharmacy.imageUrl), fit: BoxFit.cover),
                ),
                 child: const Icon(Icons.image_not_supported, color: mediumGrey), // Placeholder icon
              ),
              const SizedBox(width: 15),
              // Pharmacy Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy.address,
                      style: const TextStyle(fontSize: 13, color: darkGrey),
                       maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pharmacy.distance} away',
                      style: const TextStyle(fontSize: 13, color: darkGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Open Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pharmacy.isOpen ? primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pharmacy.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: pharmacy.isOpen ? primaryGreen : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 