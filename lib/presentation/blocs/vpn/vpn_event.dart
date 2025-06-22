part of 'vpn_bloc.dart';

abstract class VpnEvent extends Equatable {
  const VpnEvent();

  @override
  List<Object> get props => [];
}

class LoadServersEvent extends VpnEvent {}

class ConnectVpnEvent extends VpnEvent {
  final Server server;

  const ConnectVpnEvent(this.server);

  @override
  List<Object> get props => [server];
}

class DisconnectVpnEvent extends VpnEvent {
  final String sessionId;
  final String serverLocation;
  final String protocol;

  const DisconnectVpnEvent({
    required this.sessionId,
    required this.serverLocation,
    required this.protocol,
  });

  @override
  List<Object> get props => [sessionId, serverLocation, protocol];
}