class Device {
  final int id;
  final String deviceId;
  final bool isPremium;
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
      id: json['ID'] ?? 0,
      deviceId: json['DeviceID'] ?? '',
      isPremium: json['IsPremium'] ?? false,
      expiresAt: json['ExpiresAt'],
      createdAt: json['CreatedAt'] ?? '',
      updatedAt: json['UpdatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'DeviceID': deviceId,
    'IsPremium': isPremium,
    'ExpiresAt': expiresAt,
    'CreatedAt': createdAt,
    'UpdatedAt': updatedAt,
  };
}