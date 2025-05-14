import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kamui_app/domain/usecases/purchase_package_usecase.dart';
import 'dart:convert';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PurchasePackageUseCase _purchasePackageUseCase;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<String> _productIds = ['subscription_type_1', 'subscription_type_2', 'subscription_type_3'];
  
  SubscriptionBloc({
    required PurchasePackageUseCase purchasePackageUseCase,
  }) : _purchasePackageUseCase = purchasePackageUseCase,
       super(SubscriptionInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<PurchaseProductEvent>(_onPurchaseProduct);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<HandlePurchaseUpdateEvent>(_onHandlePurchaseUpdate);
    on<HandleSuccessfulPurchaseEvent>(_onHandleSuccessfulPurchase);
    
    // Listen to purchase stream and handle any pending transactions
    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {        
        // Handle any pending transactions
        for (var purchase in purchaseDetailsList) {
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase).then((_) {
            }).catchError((error) {
              Logger.error('SubscriptionBloc: Error completing pending purchase: $error');
            });
          }
        }
        
        // Process the purchase updates
        add(HandlePurchaseUpdateEvent(purchaseDetailsList));
      },
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

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
      if (response.notFoundIDs.isNotEmpty) {
        emit(SubscriptionError('Some products were not found'));
        return;
      }

      if (response.productDetails.isEmpty) {
        emit(SubscriptionError('No products available'));
        return;
      }

      // Get app name for cleaning
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final cleanedTitles = response.productDetails.map((product) {
        return product.title
            .replaceAll(RegExp(r'\s*\(.*\)'), '')
            .replaceAll('Gama VPN', appName)
            .trim();
      }).toList();
      emit(SubscriptionLoaded(response.productDetails, cleanedTitles));
    } catch (e) {
      emit(SubscriptionError('Failed to load products: $e'));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProductEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {      
      if (state is! SubscriptionLoaded) {
        emit(PurchaseError('Invalid state for purchase'));
        return;
      }

      final products = (state as SubscriptionLoaded).products;
      final product = products.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception('Product not found'),
      );      
      // Emit purchase in progress state
      emit(PurchaseInProgress());
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
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

  Future<void> _onHandlePurchaseUpdate(
    HandlePurchaseUpdateEvent event,
    Emitter<SubscriptionState> emit,
  ) async {    
    for (var purchaseDetails in event.purchaseDetailsList) {
      Logger.info('''
        Purchase Details:
        ID: ${purchaseDetails.productID}
        Status: ${purchaseDetails.status}
        Error: ${purchaseDetails.error}
      ''');
      
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        add(HandleSuccessfulPurchaseEvent(purchaseDetails));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        addError(purchaseDetails.error!);
      }
    }
  }

  Future<void> _onHandleSuccessfulPurchase(
    HandleSuccessfulPurchaseEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final purchaseDetails = event.purchaseDetails;
      Logger.info('''
        Purchase Details:
        Source: ${purchaseDetails.verificationData.source}
        Product ID: ${purchaseDetails.productID}
        Purchase token: ${purchaseDetails.verificationData.localVerificationData}
        Receipt: ${purchaseDetails.verificationData.serverVerificationData}
      ''');
      
      // Verify purchase with backend
      final isVerified = await _purchasePackageUseCase.execute(
        purchaseDetails.productID,
        purchaseDetails.verificationData.serverVerificationData,
        purchaseDetails.verificationData.source,
      );

      if (isVerified) {
        // Update device data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final deviceDataStr = prefs.getString('device_data');
        if (deviceDataStr != null) {
          final deviceData = jsonDecode(deviceDataStr);
          deviceData['is_premium'] = true;
          await prefs.setString('device_data', jsonEncode(deviceData));
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }

        // Emit success state
        emit(PurchaseSuccess(purchaseDetails));
      } else {
        emit(PurchaseError('Purchase verification failed'));
      }
    } catch (e) {
      emit(PurchaseError('Failed to handle purchase: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
} 