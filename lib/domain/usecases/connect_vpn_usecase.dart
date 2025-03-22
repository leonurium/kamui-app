import '../entities/session.dart';
import '../repositories/vpn_repository.dart';

class ConnectVpnUseCase {
  final VpnRepository repository;

  ConnectVpnUseCase(this.repository);

  Future<Session> execute(int serverId) {
    return repository.connect(serverId);
  }
}