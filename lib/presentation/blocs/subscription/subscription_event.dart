import 'package:in_app_purchase/in_app_purchase.dart';

abstract class SubscriptionEvent {}

class LoadProductsEvent extends SubscriptionEvent {}

class PurchaseProductEvent extends SubscriptionEvent {
  final String productId;
  
  PurchaseProductEvent(this.productId);
}

class RestorePurchasesEvent extends SubscriptionEvent {}

class HandlePurchaseUpdateEvent extends SubscriptionEvent {
  final List<PurchaseDetails> purchaseDetailsList;
  
  HandlePurchaseUpdateEvent(this.purchaseDetailsList);
}

class HandleSuccessfulPurchaseEvent extends SubscriptionEvent {
  final PurchaseDetails purchaseDetails;
  
  HandleSuccessfulPurchaseEvent(this.purchaseDetails);
} 