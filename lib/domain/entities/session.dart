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
    required this.totalDuration,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['ID'] ?? 0,
      sessionId: json['SessionID'] ?? '',
      userId: json['UserID'] ?? 0,
      serverId: json['ServerID'] ?? 0,
      poolId: json['PoolID'] ?? 0,
      poolName: json['PoolName'] ?? '',
      privateKey: json['PrivateKey'] ?? '',
      publicKey: json['PublicKey'] ?? '',
      endpoint: json['Endpoint'] ?? '',
      listenPort: json['ListenPort'] ?? 0,
      ipAddress: json['IPAddress'] ?? '',
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'],
      totalDuration: json['TotalDuration'] ?? 0,
      status: json['Status'] ?? '',
      createdAt: json['CreatedAt'] ?? '',
      expiresAt: json['ExpiresAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'SessionID': sessionId,
    'UserID': userId,
    'ServerID': serverId,
    'PoolID': poolId,
    'PoolName': poolName,
    'PrivateKey': privateKey,
    'PublicKey': publicKey,
    'Endpoint': endpoint,
    'ListenPort': listenPort,
    'IPAddress': ipAddress,
    'StartTime': startTime,
    'EndTime': endTime,
    'TotalDuration': totalDuration,
    'Status': status,
    'CreatedAt': createdAt,
    'ExpiresAt': expiresAt,
  };
}