part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object> get props => [message];
}

class SplashTimeoutError extends SplashState {
  final String message;

  const SplashTimeoutError(this.message);

  @override
  List<Object> get props => [message];
}