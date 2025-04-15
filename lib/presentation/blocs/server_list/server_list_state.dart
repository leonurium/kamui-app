part of 'server_list_bloc.dart';

abstract class ServerListState extends Equatable {
  const ServerListState();
  @override
  List<Object?> get props => [];
}

class ServerListInitial extends ServerListState {}

class ServerListLoading extends ServerListState {}

class ServerListLoaded extends ServerListState {
  final List<Server> premiumServers;
  final List<Server> freeServers;
  final Server? selectedServer;
  final Map<int, PingResult> pingResults;

  const ServerListLoaded({
    required this.premiumServers,
    required this.freeServers,
    this.selectedServer,
    this.pingResults = const {},
  });

  @override
  List<Object?> get props => [premiumServers, freeServers, selectedServer, pingResults];
}

class ServerListError extends ServerListState {
  final String message;

  const ServerListError(this.message);

  @override
  List<Object> get props => [message];
} 