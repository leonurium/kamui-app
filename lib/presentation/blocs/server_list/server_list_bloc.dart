import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/entities/server.dart';

part 'server_list_event.dart';
part 'server_list_state.dart';

class ServerListBloc extends Bloc<ServerListEvent, ServerListState> {
  final SharedPreferences _prefs;

  ServerListBloc(this._prefs) : super(ServerListInitial()) {
    on<LoadServersEvent>(_onLoadServers);
    on<SelectServerEvent>(_onSelectServer);
  }

  Future<void> _onLoadServers(
    LoadServersEvent event,
    Emitter<ServerListState> emit,
  ) async {
    emit(ServerListLoading());
    try {
      final serversJson = _prefs.getString('servers');
      if (serversJson == null) {
        emit(ServerListError('No servers found'));
        return;
      }

      final List<dynamic> serversList = jsonDecode(serversJson);
      final servers = serversList.map((json) => Server.fromJson(json)).toList();
      
      // Split servers into premium and free
      final premiumServers = servers.where((server) => server.isPremium).toList();
      final freeServers = servers.where((server) => !server.isPremium).toList();

      emit(ServerListLoaded(
        premiumServers: premiumServers,
        freeServers: freeServers,
        selectedServer: null,
      ));
    } catch (e) {
      emit(ServerListError(e.toString()));
    }
  }

  void _onSelectServer(
    SelectServerEvent event,
    Emitter<ServerListState> emit,
  ) {
    if (state is ServerListLoaded) {
      final currentState = state as ServerListLoaded;
      emit(ServerListLoaded(
        premiumServers: currentState.premiumServers,
        freeServers: currentState.freeServers,
        selectedServer: event.server,
      ));
    }
  }
} 