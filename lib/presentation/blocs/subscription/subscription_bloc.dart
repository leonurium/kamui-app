import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<String> _productIds = ['subscription_type_1', 'subscription_type_2', 'subscription_type_3'];
  final Set<String> _productIdSets = {'subscription_type_1', 'subscription_type_2', 'subscription_type_3'};
  
  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<PurchaseProductEvent>(_onPurchaseProduct);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        Logger.error('SubscriptionBloc: Purchase stream error: $error');
        addError(error);
      },
    );
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        Logger.error('SubscriptionBloc: In-app purchases are not available');
        emit(SubscriptionError('In-app purchases are not available'));
        return;
      }

      Logger.info('SubscriptionBloc: Loading products with IDs: $_productIdSets');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIdSets);
      Logger.info('SubscriptionBloc: Response: $response');
      
      if (response.notFoundIDs.isNotEmpty) {
        Logger.info('SubscriptionBloc: _onLoadProducts: notFoundIDs: ${response.notFoundIDs}');
        emit(SubscriptionError('Some products were not found'));
        return;
      }

      if (response.productDetails.isEmpty) {
        Logger.error('SubscriptionBloc: No products available');
        emit(SubscriptionError('No products available'));
        return;
      }

      Logger.info('SubscriptionBloc: Found ${response.productDetails.length} products');
      response.productDetails.forEach((product) {
        Logger.info('''
          Product Details:
          ID: ${product.id}
          Title: ${product.title}
          Description: ${product.description}
          Price: ${product.rawPrice}
          Currency: ${product.currencyCode}
        ''');
      });

      emit(SubscriptionLoaded(response.productDetails));
    } catch (e) {
      Logger.error('SubscriptionBloc: Failed to load products: $e');
      emit(SubscriptionError('Failed to load products: $e'));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      Logger.info('SubscriptionBloc: Attempting to purchase product: ${event.productId}');
      
      if (state is! SubscriptionLoaded) {
        Logger.error('SubscriptionBloc: Invalid state for purchase');
        emit(PurchaseError('Invalid state for purchase'));
        return;
      }

      final products = (state as SubscriptionLoaded).products;
      final product = products.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception('Product not found'),
      );

      Logger.info('SubscriptionBloc: Found product: ${product.id}');
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      Logger.error('SubscriptionBloc: Purchase failed: $e');
      emit(PurchaseError('Failed to purchase: $e'));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      Logger.info('SubscriptionBloc: Restoring purchases');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      Logger.error('SubscriptionBloc: Failed to restore purchases: $e');
      emit(SubscriptionError('Failed to restore purchases: $e'));
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    Logger.info('SubscriptionBloc: Purchase updates received: ${purchaseDetailsList.length} items');
    
    for (var purchaseDetails in purchaseDetailsList) {
      Logger.info('''
        Purchase Details:
        ID: ${purchaseDetails.productID}
        Status: ${purchaseDetails.status}
        Error: ${purchaseDetails.error}
      ''');
      
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Logger.error('SubscriptionBloc: Purchase error: ${purchaseDetails.error}');
        addError(purchaseDetails.error!);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      Logger.info('SubscriptionBloc: Handling successful purchase: ${purchaseDetails.productID}');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      
      if (purchaseDetails.pendingCompletePurchase) {
        Logger.info('SubscriptionBloc: Completing purchase');
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      Logger.error('SubscriptionBloc: Failed to handle purchase: $e');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
} 