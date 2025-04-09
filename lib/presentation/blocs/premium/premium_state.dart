part of 'premium_bloc.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumLoaded extends PremiumState {
  final List<Package> packages;

  const PremiumLoaded(this.packages);

  @override
  List<Object> get props => [packages];
}

class PremiumPurchaseSuccess extends PremiumState {}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);

  @override
  List<Object> get props => [message];
} 