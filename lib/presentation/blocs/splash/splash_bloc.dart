import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/utils/device_info.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/get_ads_usecase.dart';
import 'package:kamui_app/domain/usecases/register_device_usecase.dart';
import 'package:kamui_app/core/utils/signature.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetServersUseCase getServersUseCase;
  final GetAdsUseCase getAdsUseCase;
  final RegisterDeviceUseCase registerDeviceUseCase;

  SplashBloc({
    required this.getServersUseCase,
    required this.getAdsUseCase,
    required this.registerDeviceUseCase,
  }) : super(SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Register device
      final signature = await Signature.generate();
      final deviceId = await DeviceInfoUtil.getDeviceId();
      final registerResponse = await registerDeviceUseCase.execute(deviceId, signature);
      
      final deviceData = registerResponse.data;
      if (deviceData == null) {
        emit(SplashError('Failed to register device'));
        return;
      }

      // Save device data safely
      await prefs.setString('device_data', jsonEncode(deviceData.toJson()));

      // Get and save servers
      final servers = await getServersUseCase.execute();
      if (servers.isNotEmpty) {
        await prefs.setString('servers', jsonEncode(
          servers.map((server) => server.toJson()).toList()
        ));
      }

      // Get and save ads
      final ads = await getAdsUseCase.execute();
      if (ads.isNotEmpty) {
        await prefs.setString('ads', jsonEncode(
          ads.map((ad) => ad.toJson()).toList()
        ));
      }

      emit(SplashLoaded());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}