import 'package:kamui_app/domain/entities/package.dart';
import 'package:kamui_app/domain/entities/payment_history.dart';
import 'package:kamui_app/domain/repositories/premium_repository.dart';

class PremiumRepositoryMock implements PremiumRepository {
  @override
  Future<List<Package>> getPackages() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    return [
      Package(
        id: 1,
        name: 'Basic Plan',
        description: 'Perfect for casual users',
        price: 4.99,
        currency: 'USD',
        duration: 30,
        features: [
          'Access to all basic servers',
          'Standard connection speed',
          'Basic customer support',
          'Ad-free experience',
        ],
        isPopular: false,
      ),
      Package(
        id: 2,
        name: 'Premium Plan',
        description: 'Best value for regular users',
        price: 9.99,
        currency: 'USD',
        duration: 30,
        features: [
          'Access to all premium servers',
          'Faster connection speed',
          'Priority customer support',
          'Ad-free experience',
          'Unlimited bandwidth',
          'Dedicated IP option',
        ],
        isPopular: true,
      ),
      Package(
        id: 3,
        name: 'Pro Plan',
        description: 'For power users and businesses',
        price: 19.99,
        currency: 'USD',
        duration: 30,
        features: [
          'Access to all premium servers',
          'Ultra-fast connection speed',
          '24/7 priority support',
          'Ad-free experience',
          'Unlimited bandwidth',
          'Dedicated IP included',
          'Multiple device support',
          'Advanced security features',
        ],
        isPopular: false,
      ),
    ];
  }

  @override
  Future<bool> purchasePackage(int packageId, String purchaseToken, String platform) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return true; // Always return success in mock
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistories() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return [];
  }
} 