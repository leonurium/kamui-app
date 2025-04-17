abstract class SubscriptionEvent {}

class LoadProductsEvent extends SubscriptionEvent {}

class PurchaseProductEvent extends SubscriptionEvent {
  final String productId;
  
  PurchaseProductEvent(this.productId);
}

class RestorePurchasesEvent extends SubscriptionEvent {} 