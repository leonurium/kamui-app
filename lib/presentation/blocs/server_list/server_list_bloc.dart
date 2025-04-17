import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/domain/entities/ping_result.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/core/services/ping_service.dart';

part 'server_list_event.dart';
part 'server_list_state.dart';

class ServerListBloc extends Bloc<ServerListEvent, ServerListState> {
  final SharedPreferences _prefs;
  final GetServersUseCase _getServersUseCase;
  final PingService _pingService;
  final Map<int, PingResult> _pingResults = {};
  Timer? _pingTimer;
  List<Server> _currentServers = [];

  ServerListBloc(this._prefs, this._getServersUseCase, this._pingService) : super(ServerListInitial()) {
    on<LoadServersEvent>(_onLoadServers);
    on<SelectServerEvent>(_onSelectServer);
    on<PingServersEvent>(_onPingServers);
    on<StartPingTimerEvent>(_onStartPingTimer);
    on<StopPingTimerEvent>(_onStopPingTimer);
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentServers.isNotEmpty) {
        add(PingServersEvent(_currentServers));
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPingTimer();
    return super.close();
  }

  Future<void> _onStartPingTimer(
    StartPingTimerEvent event,
    Emitter<ServerListState> emit,
  ) async {
    _startPingTimer();
  }

  Future<void> _onStopPingTimer(
    StopPingTimerEvent event,
    Emitter<ServerListState> emit,
  ) async {
    _stopPingTimer();
  }

  Future<void> _onLoadServers(
    LoadServersEvent event,
    Emitter<ServerListState> emit,
  ) async {
    emit(ServerListLoading());
    try {
      // First try to get servers from API
      final servers = await _getServersUseCase.execute();
      _currentServers = servers;
      
      // Save servers to preferences
      final serversJson = jsonEncode(servers.map((server) => server.toJson()).toList());
      await _prefs.setString('servers', serversJson);
      
      // Split servers into premium and free
      final premiumServers = servers.where((server) => server.isPremium).toList();
      final freeServers = servers.where((server) => !server.isPremium).toList();

      emit(ServerListLoaded(
        premiumServers: premiumServers,
        freeServers: freeServers,
        selectedServer: null,
        pingResults: _pingResults,
      ));

      // Start pinging servers
      add(PingServersEvent(servers));
    } catch (e) {
      // If API fails, try to get from preferences
      try {
        final serversJson = _prefs.getString('servers');
        if (serversJson == null) {
          emit(ServerListError('No servers found'));
          return;
        }

        final List<dynamic> serversList = jsonDecode(serversJson);
        final servers = serversList.map((json) => Server.fromJson(json)).toList();
        _currentServers = servers;
        
        // Split servers into premium and free
        final premiumServers = servers.where((server) => server.isPremium).toList();
        final freeServers = servers.where((server) => !server.isPremium).toList();

        emit(ServerListLoaded(
          premiumServers: premiumServers,
          freeServers: freeServers,
          selectedServer: null,
          pingResults: _pingResults,
        ));

        // Start pinging servers
        add(PingServersEvent(servers));
      } catch (e) {
        emit(ServerListError(e.toString()));
      }
    }
  }

  Future<void> _onPingServers(
    PingServersEvent event,
    Emitter<ServerListState> emit,
  ) async {
    if (state is! ServerListLoaded) return;

    final currentState = state as ServerListLoaded;
    
    // Ping all servers in parallel
    final futures = event.servers.map((server) async {
      final result = await _pingService.pingServer(server.apiUrl);
      if(Constants.networkLogger) {
        Logger.info('Ping ${server.location}: ${result.mbps} Mbps, ${result.latency}ms');
      }
      return MapEntry(server.id, PingResult(
        serverId: server.id,
        mbps: result.mbps,
        latency: result.latency,
        isOnline: result.isOnline,
      ));
    });

    final results = await Future.wait(futures);
    final newPingResults = Map<int, PingResult>.fromEntries(results);
    
    // Create a new state with updated ping results
    final newState = ServerListLoaded(
      premiumServers: currentState.premiumServers,
      freeServers: currentState.freeServers,
      selectedServer: currentState.selectedServer,
      pingResults: newPingResults,
    );
    emit(newState);
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
        pingResults: currentState.pingResults,
      ));
    }
  }
} 