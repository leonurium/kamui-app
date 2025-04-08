import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/utils/logger.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/usecases/get_servers_usecase.dart';
import '../../../domain/usecases/connect_vpn_usecase.dart';
import '../../../domain/usecases/disconnect_vpn_usecase.dart';

part 'vpn_event.dart';
part 'vpn_state.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  final GetServersUseCase _getServersUseCase;
  final ConnectVpnUseCase _connectVpnUseCase;
  final DisconnectVpnUseCase _disconnectVpnUseCase;

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
    } catch (e) {
      emit(VpnError(e.toString()));
    }
  }

  Future<void> _onConnectVpn(
    ConnectVpnEvent event,
    Emitter<VpnState> emit,
  ) async {
    Logger.info('VpnBloc: Connecting to VPN with serverId: ${event.serverId}');
    emit(VpnConnecting());
    try {
      final session = await _connectVpnUseCase.execute(event.serverId);
      Logger.info('VpnBloc: Successfully connected to VPN. Session: $session');
      emit(VpnConnected(session));
    } catch (e) {
      Logger.error('VpnBloc: Failed to connect to VPN: $e');
      emit(VpnError(e.toString()));
    }
  }

  Future<void> _onDisconnectVpn(
    DisconnectVpnEvent event,
    Emitter<VpnState> emit,
  ) async {
    Logger.info('VpnBloc: Disconnecting from VPN with sessionId: ${event.sessionId}');
    emit(VpnDisconnecting());
    try {
      final success = await _disconnectVpnUseCase.execute(event.sessionId);
      if (success) {
        Logger.info('VpnBloc: Successfully disconnected from VPN');
        emit(VpnDisconnected());
      } else {
        Logger.error('VpnBloc: Failed to disconnect from VPN');
        emit(VpnError('Failed to disconnect'));
      }
    } catch (e) {
      Logger.error('VpnBloc: Error disconnecting from VPN: $e');
      emit(VpnError(e.toString()));
    }
  }
}