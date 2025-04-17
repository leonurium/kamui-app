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
        emit(SubscriptionError('In-app purchases are not available'));
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIdSets);
      Logger.info('SubscriptionBloc: _onLoadProducts: response: $response');
      
      if (response.notFoundIDs.isNotEmpty) {
        Logger.info('SubscriptionBloc: _onLoadProducts: notFoundIDs: ${response.notFoundIDs}');
        emit(SubscriptionError('Some products were not found'));
        return;
      }

      Logger.info('SubscriptionBloc: _onLoadProducts: productDetails: ${response.productDetails}');
      response.productDetails.forEach((product) {
        final productId = product.id;
        final productName = product.title;
        final productPrice = product.price;
        final productCurrency = product.currencyCode;
        Logger.info('SubscriptionBloc: _onLoadProducts: product: $productId, $productName, $productPrice, $productCurrency');
      });
      emit(SubscriptionLoaded(response.productDetails));
    } catch (e) {
      emit(SubscriptionError('Failed to load products: $e'));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: (state as SubscriptionLoaded)
            .products
            .firstWhere((product) => product.id == event.productId),
      );
      
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      emit(PurchaseError('Failed to purchase: $e'));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      emit(SubscriptionError('Failed to restore purchases: $e'));
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        addError(purchaseDetails.error!);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
} 