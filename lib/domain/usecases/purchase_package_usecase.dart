import '../repositories/premium_repository.dart';

class PurchasePackageUseCase {
  final PremiumRepository repository;

  PurchasePackageUseCase(this.repository);

  Future<bool> execute(String packageId, String purchaseToken, String platform) {
    return repository.purchasePackage(packageId, purchaseToken, platform);
  }
}