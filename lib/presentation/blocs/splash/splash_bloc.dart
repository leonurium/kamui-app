import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/config/constants.dart';
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

      // Get and save ads
      final ads = await getAdsUseCase.execute();
      if (ads.isNotEmpty) {
        await prefs.setString('ads', jsonEncode(
          ads.map((ad) => ad.toJson()).toList()
        ));
      } else if (Constants.isUseMockData) {
        // Add mockup ads if no ads from server
        final mockupAds = [
          {
            'id': 1,
            'title': 'Premium VPN Features',
            'media_type': 'video',
            'media_url': 'https://short.rctiplus.id/vod-e5a2a2/sv/28c0e81d-194d9aa9fc8/28c0e81d-194d9aa9fc8.mp4',
            'click_url': 'https://example.com/premium',
            'countdown': 10,
            'is_auto_clicked': false,
          },
          {
            'id': 2,
            'title': 'Fast & Secure VPN',
            'media_type': 'video',
            'media_url': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            'click_url': 'https://example.com/features',
            'countdown': 10,
            'is_auto_clicked': false,
          }
        ];
        await prefs.setString('ads', jsonEncode(mockupAds));
      }

      emit(SplashLoaded());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}