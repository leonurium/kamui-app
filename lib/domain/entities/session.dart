class Session {
  final int id;
  final String sessionId;
  final int userId;
  final int serverId;
  final int poolId;
  final String poolName;
  final String privateKey;
  final String publicKey;
  final String endpoint;
  final int listenPort;
  final String ipAddress;
  final String startTime;
  final String? endTime;
  final String lastActivity;
  final int totalDuration;
  final String status;
  final String createdAt;
  final String expiresAt;

  Session({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.serverId,
    required this.poolId,
    required this.poolName,
    required this.privateKey,
    required this.publicKey,
    required this.endpoint,
    required this.listenPort,
    required this.ipAddress,
    required this.startTime,
    this.endTime,
    required this.lastActivity,
    required this.totalDuration,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? 0,
      sessionId: json['session_id'] ?? '',
      userId: json['user_id'] ?? 0,
      serverId: json['server_id'] ?? 0,
      poolId: json['pool_id'] ?? 0,
      poolName: json['pool_name'] ?? '',
      privateKey: json['private_key'] ?? '',
      publicKey: json['public_key'] ?? '',
      endpoint: json['endpoint'] ?? '',
      listenPort: json['listen_port'] ?? 0,
      ipAddress: json['ip_address'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'],
      lastActivity: json['last_activity'] ?? '',
      totalDuration: json['total_duration'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      expiresAt: json['expires_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'session_id': sessionId,
    'user_id': userId,
    'server_id': serverId,
    'pool_id': poolId,
    'pool_name': poolName,
    'private_key': privateKey,
    'public_key': publicKey,
    'endpoint': endpoint,
    'listen_port': listenPort,
    'ip_address': ipAddress,
    'start_time': startTime,
    'end_time': endTime,
    'last_activity': lastActivity,
    'total_duration': totalDuration,
    'status': status,
    'created_at': createdAt,
    'expires_at': expiresAt,
  };
}