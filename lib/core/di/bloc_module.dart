import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/presentation/blocs/splash/splash_bloc.dart';
import 'package:kamui_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:kamui_app/presentation/blocs/server_list/server_list_bloc.dart';
import 'package:kamui_app/presentation/blocs/ads/ads_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/connect_vpn_usecase.dart';
import 'package:kamui_app/domain/usecases/disconnect_vpn_usecase.dart';
import 'package:kamui_app/domain/usecases/get_ads_usecase.dart';
import 'package:kamui_app/domain/usecases/register_device_usecase.dart';
import 'package:kamui_app/core/services/ping_service.dart';

Future<void> initBlocModule(GetIt sl) async {
  try {
    // blocs
    sl.registerLazySingleton<VpnBloc>(() => VpnBloc(
      sl<GetServersUseCase>(),
      sl<ConnectVpnUseCase>(),
      sl<DisconnectVpnUseCase>(),
    ));
    
    sl.registerLazySingleton<SplashBloc>(() => SplashBloc(
      getServersUseCase: sl<GetServersUseCase>(),
      getAdsUseCase: sl<GetAdsUseCase>(),
      registerDeviceUseCase: sl<RegisterDeviceUseCase>(),
      wireguardService: sl<WireGuardService>(),
    ));

    sl.registerLazySingleton<ServerListBloc>(() => ServerListBloc(
      sl<SharedPreferences>(),
      sl<GetServersUseCase>(),
      sl<PingService>(),
    ));

    // Onboarding bloc
    sl.registerLazySingleton<OnboardingBloc>(() => OnboardingBloc(prefs: sl<SharedPreferences>()));

    // Ads bloc
    sl.registerFactory<AdsBloc>(() => AdsBloc());
  } catch (e) {
    Logger.error('Error in bloc module initialization: $e');
    rethrow;
  }
} 