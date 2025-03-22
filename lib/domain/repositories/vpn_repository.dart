import '../entities/server.dart';
import '../entities/session.dart';

abstract class VpnRepository {
  Future<List<Server>> getServers();
  Future<Session> connect(int serverId);
  Future<bool> disconnect(int sessionId);
}
