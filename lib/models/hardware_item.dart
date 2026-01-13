class HardwareItem {
  final int id;
  final String name;
  final String type; // GPU, CPU, etc.
  final double price;
  final String brand;
  final String imageUrl;

  HardwareItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.brand,
    required this.imageUrl,
  });

  factory HardwareItem.fromJson(Map<String, dynamic> json) {
    return HardwareItem(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'Misc',
      price: (json['price'] as num).toDouble(),
      brand: json['brand'] ?? 'Generic',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
