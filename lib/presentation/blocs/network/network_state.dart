part of 'network_bloc.dart';

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkMonitoringStarted extends NetworkState {}

class NetworkMonitoringStopped extends NetworkState {}

class NetworkStatusUpdated extends NetworkState {
  final bool isReachable;

  const NetworkStatusUpdated(this.isReachable);

  @override
  List<Object> get props => [isReachable];
}

class NetworkDisconnected extends NetworkState {} 