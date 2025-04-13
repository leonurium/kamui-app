import 'package:kamui_app/domain/entities/pool.dart';
import 'package:kamui_app/domain/entities/session.dart';

class ConnectionData {
  final Pool pool;
  final Session session;

  ConnectionData({
    required this.pool,
    required this.session,
  });

  factory ConnectionData.fromJson(Map<String, dynamic> json) {
    return ConnectionData(
      pool: Pool.fromJson(json['pool'] ?? {}),
      session: Session.fromJson(json['session'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'pool': pool.toJson(),
    'session': session.toJson(),
  };
} 