import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/services/analytics_service.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/connect_vpn_usecase.dart';
import 'package:kamui_app/domain/usecases/disconnect_vpn_usecase.dart';

part 'vpn_event.dart';
part 'vpn_state.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  final GetServersUseCase _getServersUseCase;
  final ConnectVpnUseCase _connectVpnUseCase;
  final DisconnectVpnUseCase _disconnectVpnUseCase;
  DateTime? _connectionStartTime;
  String? _currentServerLocation;
  String? _currentProtocol;

  VpnBloc(
    this._getServersUseCase,
    this._connectVpnUseCase,
    this._disconnectVpnUseCase,
  ) : super(VpnInitial()) {
    on<LoadServersEvent>(_onLoadServers);
    on<ConnectVpnEvent>(_onConnectVpn);
    on<DisconnectVpnEvent>(_onDisconnectVpn);
  }

  Future<void> _onLoadServers(
    LoadServersEvent event,
    Emitter<VpnState> emit,
  ) async {
    emit(VpnLoading());
    try {
      final servers = await _getServersUseCase.execute();
      emit(VpnServersLoaded(servers));
      
      // Track server list load
      await AnalyticsService.logFeatureUsage(
        featureName: 'server_list',
        action: 'load',
        additionalParams: {
          'server_count': servers.length,
        },
      );
    } catch (e) {
      emit(VpnError(e.toString()));
      // Track error
      await AnalyticsService.logAppCrash(
        error: e.toString(),
        stackTrace: '',
        screenName: 'server_list',
      );
    }
  }

  Future<void> _onConnectVpn(
    ConnectVpnEvent event,
    Emitter<VpnState> emit,
  ) async {
    emit(VpnConnecting());
    try {
      final connectionData = await _connectVpnUseCase.execute(event.server);
      _connectionStartTime = DateTime.now();
      _currentServerLocation = connectionData.session.poolName; // Using poolName as server location
      _currentProtocol = 'WireGuard'; // Assuming WireGuard protocol
      emit(VpnConnected(connectionData));
      
      // Track VPN connection
      await AnalyticsService.logVpnConnect(
        serverLocation: _currentServerLocation!,
        protocol: _currentProtocol!,
        connectionType: 'mobile',
      );
      
      // Track feature usage
      await AnalyticsService.logFeatureUsage(
        featureName: 'vpn_connection',
        action: 'connect',
        additionalParams: {
          'server_location': _currentServerLocation,
          'protocol': _currentProtocol,
        },
      );
    } catch (e) {
      emit(VpnError(e.toString()));

      // Track connection failure
      await AnalyticsService.logAppCrash(
        error: e.toString(),
        stackTrace: '',
        screenName: 'vpn_connection',
      );
    }
  }

  Future<void> _onDisconnectVpn(
    DisconnectVpnEvent event,
    Emitter<VpnState> emit,
  ) async {
    emit(VpnDisconnecting());
    try {
      final success = await _disconnectVpnUseCase.execute(event.sessionId);
      if (success) {
        emit(VpnDisconnected());
        
        // Calculate connection duration
        final durationInSeconds = _connectionStartTime != null
            ? DateTime.now().difference(_connectionStartTime!).inSeconds
            : 0;
        
        // Track VPN disconnection
        await AnalyticsService.logVpnDisconnect(
          serverLocation: event.serverLocation,
          protocol: event.protocol,
          connectionType: 'mobile',
          durationInSeconds: durationInSeconds,
        );
        
        // Track feature usage
        await AnalyticsService.logFeatureUsage(
          featureName: 'vpn_connection',
          action: 'disconnect',
          additionalParams: {
            'server_location': event.serverLocation,
            'protocol': event.protocol,
            'duration_seconds': durationInSeconds,
          },
        );
        
        // Reset connection tracking
        _connectionStartTime = null;
        _currentServerLocation = null;
        _currentProtocol = null;
      } else {
        emit(VpnError('Failed to disconnect'));
        
        // Track disconnection failure
        await AnalyticsService.logAppCrash(
          error: 'Failed to disconnect',
          stackTrace: '',
          screenName: 'vpn_connection',
        );
      }
    } catch (e) {
      emit(VpnError(e.toString()));
      
      // Track disconnection error
      await AnalyticsService.logAppCrash(
        error: e.toString(),
        stackTrace: '',
        screenName: 'vpn_connection',
      );
    }
  }
}