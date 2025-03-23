import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/utils/device_info.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/get_ads_usecase.dart';
import 'package:kamui_app/domain/usecases/register_device_usecase.dart';
import 'package:kamui_app/core/utils/signature.dart';
import 'package:kamui_app/core/utils/logger.dart';

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
      // Generate device signature
      final signature = await Signature.generate();
      final deviceId = await DeviceInfoUtil.getDeviceId();
      
      // Register device if not registered
      final isRegistered = await registerDeviceUseCase.execute(
        deviceId, // Get from device
        signature,
      );

      if (!isRegistered) {
        emit(SplashError('Failed to register device'));
        return;
      }

      // Get servers and ads
      final servers = await getServersUseCase.execute();
      final ads = await getAdsUseCase.execute();

      for (var server in servers) {
        Logger.debug(server.ip);
      }

      for (var ad in ads) {
        Logger.debug(ad.title);
      }
      
      // Save to local storage
      // TODO: Implement local storage saving

      emit(SplashLoaded());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}