class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String distance;
  final bool isOpen;
  final String imageUrl; // Placeholder for image
  final double? latitude;
  final double? longitude;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.isOpen,
    required this.imageUrl,
    this.latitude,
    this.longitude,
  });
}
