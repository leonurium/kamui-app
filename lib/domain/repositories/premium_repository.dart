import '../entities/package.dart';
import '../entities/payment_history.dart';

abstract class PremiumRepository {
  Future<List<Package>> getPackages();
  Future<bool> purchasePackage(String packageId, String purchaseToken, String platform);
  Future<List<PaymentHistory>> getPaymentHistories();
}