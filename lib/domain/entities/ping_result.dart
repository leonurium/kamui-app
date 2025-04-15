class PingResult {
  final int serverId;
  final double mbps;
  final int latency;
  final bool isOnline;

  PingResult({
    required this.serverId,
    required this.mbps,
    required this.latency,
    required this.isOnline,
  });

  factory PingResult.fromJson(Map<String, dynamic> json) {
    return PingResult(
      serverId: json['server_id'] ?? 0,
      mbps: (json['mbps'] ?? 0.0).toDouble(),
      latency: json['latency'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_id': serverId,
      'mbps': mbps,
      'latency': latency,
      'is_online': isOnline,
    };
  }
} 