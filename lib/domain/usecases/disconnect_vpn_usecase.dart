import '../repositories/vpn_repository.dart';

class DisconnectVpnUseCase {
  final VpnRepository repository;

  DisconnectVpnUseCase(this.repository);

  Future<bool> execute(String sessionId) {
    return repository.disconnect(sessionId);
  }
}