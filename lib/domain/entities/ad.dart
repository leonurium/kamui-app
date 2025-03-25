class Ad {
  final int id;
  final String title;
  final String mediaType;
  final String mediaUrl;
  final String clickUrl;
  final int countdown;

  Ad({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.mediaUrl,
    required this.clickUrl,
    required this.countdown,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      mediaType: json['media_type'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      clickUrl: json['click_url'] ?? '',
      countdown: json['countdown'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'click_url': clickUrl,
      'countdown': countdown,
    };
  }
}