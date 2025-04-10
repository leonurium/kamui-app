class Package {
  final int id;
  final String name;
  final String description;
  final double price;
  final double priceAfterDiscount;
  final String currency;
  final int duration; // in days
  final int discount;
  final String status;
  final List<String> features;
  final bool isPopular;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceAfterDiscount,
    required this.currency,
    required this.duration,
    required this.discount,
    required this.status,
    required this.features,
    this.isPopular = false,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    // Mock data for missing fields
    final mockFeatures = [
      'Unlimited bandwidth',
      'Access to all servers',
      'No ads',
      'Priority support',
      'High-speed connection'
    ];
    
    final mockDescriptions = {
      1: 'Perfect for trying out our premium features',
      2: 'Great value for regular users',
      3: 'Best value for long-term users'
    };

    return Package(
      id: json['id'],
      name: json['name'],
      description: mockDescriptions[json['id']] ?? 'Premium VPN package',
      price: json['price'].toDouble(),
      priceAfterDiscount: json['price_after_discount'].toDouble(),
      currency: 'USD', // Default currency
      duration: json['duration'],
      discount: json['discount'],
      status: json['status'],
      features: mockFeatures,
      isPopular: json['id'] == 3, // Mark 1-year plan as popular
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'price_after_discount': priceAfterDiscount,
      'currency': currency,
      'duration': duration,
      'discount': discount,
      'status': status,
      'features': features,
      'is_popular': isPopular,
    };
  }
}