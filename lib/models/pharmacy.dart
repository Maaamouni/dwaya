class Pharmacy {
  final String id;
  final String name;
  final String address;
  double? distance; // Changed to nullable double for calculated distance
  final bool isOpen;
  final String imageUrl; // Placeholder for image
  final double? latitude;
  final double? longitude;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.isOpen,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.distance, // Make distance optional in constructor
  });
}
