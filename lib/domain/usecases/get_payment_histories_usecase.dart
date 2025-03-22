import '../entities/payment_history.dart';
import '../repositories/premium_repository.dart';

class GetPaymentHistoriesUseCase {
  final PremiumRepository repository;

  GetPaymentHistoriesUseCase(this.repository);

  Future<List<PaymentHistory>> execute() {
    return repository.getPaymentHistories();
  }
}