import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/entities/package.dart';
import '../../domain/entities/payment_history.dart';
import '../../core/utils/logger.dart';

class InAppPurchaseRepository implements PremiumRepository {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  InAppPurchaseRepository() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (await _inAppPurchase.isAvailable()) {
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          Logger.error('Error in purchase stream: $error');
        },
      );

      await _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({
        'subscription_type_1',
        'subscription_type_2',
        'subscription_type_3',
      });

      if (response.notFoundIDs.isNotEmpty) {
        Logger.warning('Products not found: ${response.notFoundIDs}');
      }

      _products.clear();
      _products.addAll(response.productDetails);
    } catch (e) {
      Logger.error('Error loading products: $e');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Logger.info('Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Logger.error('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Here you would typically verify the purchase with your backend
    // For now, we'll just acknowledge the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  @override
  Future<List<Package>> getPackages() async {
    return _products.map((product) {
      final isPopular = product.id == 'subscription_type_3';
      final price = product.rawPrice;
      final discount = isPopular ? 20 : 0;
      final priceAfterDiscount = price * (1 - discount / 100);

      return Package(
        id: _getPackageId(product.id),
        name: product.title,
        description: product.description,
        price: price,
        priceAfterDiscount: priceAfterDiscount,
        currency: product.currencyCode,
        duration: _getDuration(product.id),
        discount: discount,
        status: 'active',
        features: [
          'Access to all premium servers',
          'Faster connection speed',
          'Priority customer support',
          'Ad-free experience',
          'Unlimited bandwidth',
          if (isPopular) 'Dedicated IP included',
        ],
        isPopular: isPopular,
      );
    }).toList();
  }

  int _getPackageId(String productId) {
    switch (productId) {
      case 'subscription_type_1':
        return 1;
      case 'subscription_type_2':
        return 2;
      case 'subscription_type_3':
        return 3;
      default:
        return 0;
    }
  }

  int _getDuration(String productId) {
    switch (productId) {
      case 'subscription_type_1':
        return 7;
      case 'subscription_type_2':
        return 30;
      case 'subscription_type_3':
        return 60;
      default:
        return 0;
    }
  }

  @override
  Future<bool> purchasePackage(int packageId, String purchaseToken, String platform) async {
    try {
      final productId = _getProductId(packageId);
      final product = _products.firstWhere((p) => p.id == productId);
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      Logger.error('Error purchasing package: $e');
      return false;
    }
  }

  String _getProductId(int packageId) {
    switch (packageId) {
      case 1:
        return 'subscription_type_1';
      case 2:
        return 'subscription_type_2';
      case 3:
        return 'subscription_type_3';
      default:
        return '';
    }
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistories() async {
    // This would typically be implemented by fetching from your backend
    return [];
  }

  void dispose() {
    _subscription?.cancel();
  }
} 