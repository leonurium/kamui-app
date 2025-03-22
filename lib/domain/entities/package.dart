class Package {
  final int id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final String currency;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.currency,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      currency: json['currency'],
    );
  }
}