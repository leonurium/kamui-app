class Server {
  final int id;
  final String name;
  final String country;
  final String ip;
  final String image;
  final bool isPremium;
  final int ping;

  Server({
    required this.id,
    required this.name,
    required this.country,
    required this.ip,
    required this.image,
    required this.isPremium,
    required this.ping,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      ip: json['ip'],
      image: json['image'],
      isPremium: json['is_premium'] ?? false,
      ping: json['ping'] ?? 0,
    );
  }
}