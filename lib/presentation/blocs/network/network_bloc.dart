import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/services/network_reachability_service.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/core/utils/logger.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkReachabilityService _reachabilityService;
  final WireGuardService _wireguardService;
  StreamSubscription? _reachabilitySubscription;
  bool _isMonitoring = false;

  NetworkBloc({
    required NetworkReachabilityService reachabilityService,
    required WireGuardService wireguardService,
  })  : _reachabilityService = reachabilityService,
        _wireguardService = wireguardService,
        super(NetworkInitial()) {
    
    on<StartNetworkMonitoring>(_onStartMonitoring);
    on<StopNetworkMonitoring>(_onStopMonitoring);
    on<NetworkStatusChanged>(_onNetworkStatusChanged);
  }

  Future<void> _onStartMonitoring(
    StartNetworkMonitoring event,
    Emitter<NetworkState> emit,
  ) async {
    if (_isMonitoring) {
      return;
    }

    try {
      _reachabilitySubscription?.cancel();
      _reachabilitySubscription = _reachabilityService.reachabilityStream.listen(
        (isReachable) => add(NetworkStatusChanged(isReachable)),
        onError: (error) {
          Logger.error('Reachability stream error: $error');
          add(NetworkStatusChanged(false));
        },
      );

      _reachabilityService.startMonitoring();
      _isMonitoring = true;
      emit(NetworkMonitoringStarted());
    } catch (e) {
      Logger.error('Failed to start monitoring: $e');
      _isMonitoring = false;
    }
  }

  Future<void> _onStopMonitoring(
    StopNetworkMonitoring event,
    Emitter<NetworkState> emit,
  ) async {
    if (!_isMonitoring) {
      Logger.warning('Network monitoring not running');
      return;
    }

    try {
      _reachabilitySubscription?.cancel();
      _reachabilityService.stopMonitoring();
      _isMonitoring = false;
      emit(NetworkMonitoringStopped());
    } catch (e) {
      Logger.error('Failed to stop monitoring: $e');
    }
  }

  Future<void> _onNetworkStatusChanged(
    NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) async {
    emit(NetworkStatusUpdated(event.isReachable));
    
    if (!event.isReachable) {
      await _handleNetworkDisconnection(emit);
    }
  }

  Future<void> _handleNetworkDisconnection(Emitter<NetworkState> emit) async {
    try {
      final isConnected = await _wireguardService.isConnected();
      if (isConnected) {
        await _wireguardService.disconnect();
        emit(NetworkDisconnected());
      }
    } catch (e) {
      Logger.error('Failed to handle VPN disconnection: $e');
    }
  }

  @override
  Future<void> close() {
    _reachabilitySubscription?.cancel();
    _reachabilityService.dispose();
    _isMonitoring = false;
    return super.close();
  }
} 