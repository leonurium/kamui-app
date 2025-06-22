import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/server.dart';

abstract class VpnRepository {
  Future<List<Server>> getServers();
  Future<ConnectionData> connect(Server server);
  Future<bool> disconnect(String sessionId);
}
