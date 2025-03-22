import '../entities/package.dart';
import '../repositories/premium_repository.dart';

class GetPackagesUseCase {
  final PremiumRepository repository;

  GetPackagesUseCase(this.repository);

  Future<List<Package>> execute() {
    return repository.getPackages();
  }
}