import '../repositories/vpn_repository.dart';

class DisconnectVpnUseCase {
  final VpnRepository repository;

  DisconnectVpnUseCase(this.repository);

  Future<bool> execute(int sessionId) {
    return repository.disconnect(sessionId);
  }
}