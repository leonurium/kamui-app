part of 'network_bloc.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object> get props => [];
}

class StartNetworkMonitoring extends NetworkEvent {}

class StopNetworkMonitoring extends NetworkEvent {}

class NetworkStatusChanged extends NetworkEvent {
  final bool isReachable;

  const NetworkStatusChanged(this.isReachable);

  @override
  List<Object> get props => [isReachable];
} 