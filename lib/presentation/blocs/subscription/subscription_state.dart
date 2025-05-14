import 'package:in_app_purchase/in_app_purchase.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<ProductDetails> products;
  final List<String> cleanedTitles;
  
  SubscriptionLoaded(this.products, this.cleanedTitles);
}

class SubscriptionError extends SubscriptionState {
  final String message;
  
  SubscriptionError(this.message);
}

class PurchaseSuccess extends SubscriptionState {
  final PurchaseDetails purchase;
  
  PurchaseSuccess(this.purchase);
}

class PurchaseError extends SubscriptionState {
  final String message;
  
  PurchaseError(this.message);
}

class PurchaseInProgress extends SubscriptionState {} 