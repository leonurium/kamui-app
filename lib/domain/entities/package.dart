class Package {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int duration; // in days
  final List<String> features;
  final bool isPopular;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      duration: json['duration'],
      features: List<String>.from(json['features']),
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration': duration,
      'features': features,
      'is_popular': isPopular,
    };
  }
}