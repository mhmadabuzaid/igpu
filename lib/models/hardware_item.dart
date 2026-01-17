class HardwareItem {
  final int id;
  final String name;
  final String type;
  final double price;
  final String brand;
  final String imageUrl;
  final String description; // 1. New Field

  HardwareItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.brand,
    required this.imageUrl,
    required this.description, // 2. Required in constructor
  });

  factory HardwareItem.fromJson(Map<String, dynamic> json) {
    return HardwareItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      type: json['type']?.toString() ?? 'Misc',

      // Handle price safely (int or double)
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,

      brand: json['brand']?.toString() ?? 'Generic',
      imageUrl: json['image_url']?.toString() ?? '',

      // 3. Parse the description safely
      description:
          json['description']?.toString() ?? 'No description available.',
    );
  }
}
