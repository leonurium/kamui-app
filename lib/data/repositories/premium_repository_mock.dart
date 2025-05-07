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
        name: '1 Month Premium',
        description: 'Perfect for trying out our premium features',
        price: 9.99,
        priceAfterDiscount: 9.99,
        currency: 'USD',
        duration: 30,
        discount: 0,
        status: 'active',
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
        name: '3 Months Premium',
        description: 'Great value for regular users',
        price: 24.99,
        priceAfterDiscount: 23.74,
        currency: 'USD',
        duration: 90,
        discount: 5,
        status: 'active',
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
        name: '1 Year Premium',
        description: 'Best value for long-term users',
        price: 79.99,
        priceAfterDiscount: 63.99,
        currency: 'USD',
        duration: 365,
        discount: 20,
        status: 'active',
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
  Future<bool> purchasePackage(String packageId, String purchaseToken, String platform) async {
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