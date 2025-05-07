class Device {
  final int id;
  final String deviceId;
  bool isPremium;
  final String? expiresAt;
  final String createdAt;
  final String updatedAt;

  Device({
    required this.id,
    required this.deviceId,
    required this.isPremium,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      isPremium: json['is_premium'] ?? false,
      expiresAt: json['expires_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_id': deviceId,
    'is_premium': isPremium,
    'expires_at': expiresAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}