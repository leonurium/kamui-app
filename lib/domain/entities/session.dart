class Session {
  final int id;
  final String serverId;
  final String serverName;
  final String serverIp;
  final String startTime;
  final String endTime;
  final String duration;
  final String status;
  final String? privateKey;
  final String? publicKey;
  final String? presharedKey;
  final String? endpoint;
  final String? allowedIps;
  final String? dns;
  final String serverAddress;
  final String dnsServer;
  final String clientPrivateKey;
  final String clientPublicKey;
  final String serverPublicKey;
  final int serverPort;
  final String serverEndpoint;

  Session({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.serverIp,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    this.privateKey,
    this.publicKey,
    this.presharedKey,
    this.endpoint,
    this.allowedIps,
    this.dns,
    required this.serverAddress,
    required this.dnsServer,
    required this.clientPrivateKey,
    required this.clientPublicKey,
    required this.serverPublicKey,
    required this.serverPort,
    required this.serverEndpoint,
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
      privateKey: json['private_key'],
      publicKey: json['public_key'],
      presharedKey: json['preshared_key'],
      endpoint: json['endpoint'],
      allowedIps: json['allowed_ips'],
      dns: json['dns'],
      serverAddress: json['server_address'],
      dnsServer: json['dns_server'],
      clientPrivateKey: json['client_private_key'],
      clientPublicKey: json['client_public_key'],
      serverPublicKey: json['server_public_key'],
      serverPort: json['server_port'],
      serverEndpoint: json['server_endpoint'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'server_id': serverId,
    'server_name': serverName,
    'server_ip': serverIp,
    'start_time': startTime,
    'end_time': endTime,
    'duration': duration,
    'status': status,
    'private_key': privateKey,
    'public_key': publicKey,
    'preshared_key': presharedKey,
    'endpoint': endpoint,
    'allowed_ips': allowedIps,
    'dns': dns,
    'server_address': serverAddress,
    'dns_server': dnsServer,
    'client_private_key': clientPrivateKey,
    'client_public_key': clientPublicKey,
    'server_public_key': serverPublicKey,
    'server_port': serverPort,
    'server_endpoint': serverEndpoint,
  };
}