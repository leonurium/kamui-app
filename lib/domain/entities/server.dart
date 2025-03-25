class Server {
  final int id;
  final String apiUrl;
  final String city;
  final String country;
  final bool isLocked;
  final bool isPremium;

  Server({
    required this.id,
    required this.apiUrl,
    required this.city,
    required this.country,
    required this.isLocked,
    required this.isPremium,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] ?? 0,
      apiUrl: json['api_url'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      isLocked: json['is_locked'] ?? false,
      isPremium: json['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'api_url': apiUrl,
      'city': city,
      'country': country,
      'is_locked': isLocked,
      'is_premium': isPremium,
    };
  }
}