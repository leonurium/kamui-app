part of 'vpn_bloc.dart';

abstract class VpnEvent extends Equatable {
  const VpnEvent();

  @override
  List<Object> get props => [];
}

class LoadServersEvent extends VpnEvent {}

class ConnectVpnEvent extends VpnEvent {
  final int serverId;

  const ConnectVpnEvent(this.serverId);

  @override
  List<Object> get props => [serverId];
}

class DisconnectVpnEvent extends VpnEvent {
  final String sessionId;

  const DisconnectVpnEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}