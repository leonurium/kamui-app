class Session {
  final int id;
  final String serverId;
  final String serverName;
  final String serverIp;
  final String startTime;
  final String endTime;
  final String duration;
  final String status;

  Session({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.serverIp,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      serverId: json['server_id'],
      serverName: json['server_name'],
      serverIp: json['server_ip'],
      startTime: json['start_time'],
      endTime: json['end_time'] ?? '',
      duration: json['duration'] ?? '',
      status: json['status'],
    );
  }
}