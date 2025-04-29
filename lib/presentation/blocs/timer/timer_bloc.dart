import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/core/config/constants.dart';

abstract class TimerEvent {}

class StartTimerEvent extends TimerEvent {
  final ConnectionData connectionData;
  final bool isPremium;
  final DateTime startTime;

  StartTimerEvent(this.connectionData, this.isPremium, {DateTime? startTime}) 
    : this.startTime = startTime ?? DateTime.now();
}

class StopTimerEvent extends TimerEvent {}

class TimerTickEvent extends TimerEvent {}

abstract class TimerState {}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final String duration;
  final bool shouldShowAds;
  final bool shouldDisconnect;
  final ConnectionData connectionData;
  final bool isPremium;
  final DateTime startTime;

  TimerRunning({
    required this.duration,
    required this.connectionData,
    required this.isPremium,
    required this.startTime,
    this.shouldShowAds = false,
    this.shouldDisconnect = false,
  });
}

class TimerStopped extends TimerState {}

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _timer;
  TimerBloc() : super(TimerInitial()) {
    on<StartTimerEvent>(_onStartTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);
  }

  void _onStartTimer(StartTimerEvent event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = null;
    
    // Reset to initial state first
    emit(TimerInitial());
    
    // Emit initial running state with current time
    emit(TimerRunning(
      duration: "00:00:00",
      connectionData: event.connectionData,
      isPremium: event.isPremium,
      startTime: event.startTime,
    ));

    // Start periodic timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Logger.info('Timer tick event ${timer.tick}');
      add(TimerTickEvent());
    });
  }

  void _onStopTimer(StopTimerEvent event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(TimerStopped());
  }

  void _onTimerTick(TimerTickEvent event, Emitter<TimerState> emit) {
    if (state is TimerRunning) {
      final currentState = state as TimerRunning;
      final now = DateTime.now();
      final diff = now.difference(currentState.startTime);
      
      // For free users, check if time limit has passed
      if (!currentState.isPremium) {
        final timeLimit = Constants.isUseMockData ? 1 : 30; // 1 minute for mock, 30 minutes for real
        if (diff.inMinutes >= timeLimit) {
          emit(TimerRunning(
            duration: "${timeLimit.toString().padLeft(2, '0')}:00:00",
            shouldShowAds: true,
            shouldDisconnect: true,
            connectionData: currentState.connectionData,
            isPremium: currentState.isPremium,
            startTime: currentState.startTime,
          ));
          return;
        }
      }

      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      final duration = "$hours:$minutes:$seconds";
      
      emit(TimerRunning(
        duration: duration,
        shouldShowAds: false,
        shouldDisconnect: false,
        connectionData: currentState.connectionData,
        isPremium: currentState.isPremium,
        startTime: currentState.startTime,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }
} 