part of 'vpn_bloc.dart';

abstract class VpnState extends Equatable {
  const VpnState();
  
  @override
  List<Object?> get props => [];
}

class VpnInitial extends VpnState {}

class VpnLoading extends VpnState {}

class VpnServersLoaded extends VpnState {
  final List<Server> servers;

  const VpnServersLoaded(this.servers);

  @override
  List<Object> get props => [servers];
}

class VpnConnecting extends VpnState {}

class VpnConnected extends VpnState {
  final ConnectionData connectionData;

  const VpnConnected(this.connectionData);

  @override
  List<Object> get props => [connectionData];
}

class VpnDisconnecting extends VpnState {}

class VpnDisconnected extends VpnState {}

class VpnError extends VpnState {
  final String message;

  const VpnError(this.message);

  @override
  List<Object> get props => [message];
}