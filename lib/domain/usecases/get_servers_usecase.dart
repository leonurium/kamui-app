import '../entities/server.dart';
import '../repositories/vpn_repository.dart';

class GetServersUseCase {
  final VpnRepository repository;

  GetServersUseCase(this.repository);

  Future<List<Server>> execute() {
    return repository.getServers();
  }
}