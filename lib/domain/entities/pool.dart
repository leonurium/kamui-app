class Pool {
  final int id;
  final String name;
  final int serverId;
  final String publicKey;
  final String endpoint;
  final int persistentKeepalive;
  final String allowedIps;
  final String presharedKey;
  final String dns;
  final String createdAt;
  final String updatedAt;

  Pool({
    required this.id,
    required this.name,
    required this.serverId,
    required this.publicKey,
    required this.endpoint,
    required this.persistentKeepalive,
    required this.allowedIps,
    required this.presharedKey,
    required this.dns,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      serverId: json['server_id'] ?? 0,
      publicKey: json['public_key'] ?? '',
      endpoint: json['endpoint'] ?? '',
      persistentKeepalive: json['persistent_keepalive'] ?? 0,
      allowedIps: json['allowed_ips'] ?? '',
      presharedKey: json['preshared_key'] ?? '',
      dns: json['dns'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'server_id': serverId,
    'public_key': publicKey,
    'endpoint': endpoint,
    'persistent_keepalive': persistentKeepalive,
    'allowed_ips': allowedIps,
    'preshared_key': presharedKey,
    'dns': dns,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
} 