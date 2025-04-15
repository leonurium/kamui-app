part of 'server_list_bloc.dart';

abstract class ServerListEvent extends Equatable {
  const ServerListEvent();

  @override
  List<Object> get props => [];
}

class LoadServersEvent extends ServerListEvent {}

class SelectServerEvent extends ServerListEvent {
  final Server server;

  const SelectServerEvent(this.server);

  @override
  List<Object> get props => [server];
}

class PingServersEvent extends ServerListEvent {
  final List<Server> servers;

  const PingServersEvent(this.servers);

  @override
  List<Object> get props => [servers];
}

class StartPingTimerEvent extends ServerListEvent {}

class StopPingTimerEvent extends ServerListEvent {} 