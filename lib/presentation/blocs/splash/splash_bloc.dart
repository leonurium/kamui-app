import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/utils/device_info.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/get_ads_usecase.dart';
import 'package:kamui_app/domain/usecases/register_device_usecase.dart';
import 'package:kamui_app/core/utils/signature.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetServersUseCase getServersUseCase;
  final GetAdsUseCase getAdsUseCase;
  final RegisterDeviceUseCase registerDeviceUseCase;
  final WireGuardService _wireguardService;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  SplashBloc({
    required this.getServersUseCase,
    required this.getAdsUseCase,
    required this.registerDeviceUseCase,
    required WireGuardService wireguardService,
  })  : _wireguardService = wireguardService,
        super(SplashInitial()) {
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
        await _handleRegistrationFailure(emit);
        return;
      }

      // Reset retry count on successful registration
      _retryCount = 0;

      // Save device data safely
      // deviceData.isPremium = true; // force isPremium status
      await prefs.setString('device_data', jsonEncode(deviceData.toJson()));

      // Get and save ads
      final ads = await getAdsUseCase.execute();
      if (ads.isNotEmpty) {
        // Separate ads by media type
        final interstitialAds = ads.where((ad) => ad.mediaType == 'video' || ad.mediaType == 'image').toList();
        final bannerAds = ads.where((ad) => ad.mediaType == 'banner').toList();

        // Save interstitial ads
        if (interstitialAds.isNotEmpty) {
          await prefs.setString('ads_interstitial', jsonEncode(
            interstitialAds.map((ad) => ad.toJson()).toList()
          ));
        }

        // Save banner ads
        if (bannerAds.isNotEmpty) {
          await prefs.setString('ads_banner', jsonEncode(
            bannerAds.map((ad) => ad.toJson()).toList()
          ));
        }
      } else if (Constants.isUseMockData) {
        // Add mockup ads if no ads from server
        final mockupInterstitialAds = [
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

        final mockupBannerAds = [
          {
            'id': 3,
            'title': 'Special Offer',
            'media_type': 'banner',
            'media_url': 'https://www.lipsum.com/images/banners/grey_468x60.gif',
            'click_url': 'https://example.com/offer',
            'countdown': 0,
            'is_auto_clicked': false,
          }
        ];

        await prefs.setString('ads_interstitial', jsonEncode(mockupInterstitialAds));
        await prefs.setString('ads_banner', jsonEncode(mockupBannerAds));
      }

      emit(SplashLoaded());
    } catch (e) {
      Logger.error('Error during initialization: $e');
      await _handleRegistrationFailure(emit);
    }
  }

  Future<void> _handleRegistrationFailure(Emitter<SplashState> emit) async {
    _retryCount++;
    
    if (_retryCount >= _maxRetries) {
      emit(SplashError('Failed to register device after ${_maxRetries} attempts'));
      return;
    }

    try {
      // Check if VPN is connected
      await _wireguardService.initialize();
      final isConnected = await _wireguardService.isConnected();
      if (isConnected) {
        await _wireguardService.disconnect();
      } else {
        emit(SplashTimeoutError('Connection timeout. Please check your internet connection and try again.'));
      }

      // Add a small delay before retrying
      await Future.delayed(const Duration(seconds: 10));
      
      // Retry the initialization
      add(InitializeApp());
    } catch (e) {
      Logger.error('Error during retry attempt: $e');
      emit(SplashTimeoutError('Connection timeout. Please check your internet connection and try again.'));
    }
  }
}