import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/domain/repositories/vpn_repository.dart';

class ConnectVpnUseCase {
  final VpnRepository repository;

  ConnectVpnUseCase(this.repository);

  Future<ConnectionData> execute(Server server) {
    return repository.connect(server);
  }
}