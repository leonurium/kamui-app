class Ad {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
    );
  }
}