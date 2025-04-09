part of 'premium_bloc.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object> get props => [];
}

class LoadPackages extends PremiumEvent {}

class PurchasePackage extends PremiumEvent {
  final int packageId;
  final String purchaseToken;
  final String platform;

  const PurchasePackage({
    required this.packageId,
    required this.purchaseToken,
    required this.platform,
  });

  @override
  List<Object> get props => [packageId, purchaseToken, platform];
} 