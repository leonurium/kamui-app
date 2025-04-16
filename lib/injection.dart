// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/presentation/blocs/splash/splash_bloc.dart';
import 'package:kamui_app/presentation/blocs/premium/premium_bloc.dart';
import 'package:kamui_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/vpn_repository_impl.dart';
import 'data/repositories/premium_repository_impl.dart';
import 'data/repositories/ads_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/vpn_repository.dart';
import 'domain/repositories/premium_repository.dart';
import 'domain/repositories/ads_repository.dart';
import 'domain/usecases/register_device_usecase.dart';
import 'domain/usecases/get_servers_usecase.dart';
import 'domain/usecases/connect_vpn_usecase.dart';
import 'domain/usecases/disconnect_vpn_usecase.dart';
import 'domain/usecases/get_packages_usecase.dart';
import 'domain/usecases/purchase_package_usecase.dart';
import 'domain/usecases/get_payment_histories_usecase.dart';
import 'domain/usecases/get_ads_usecase.dart';
import 'presentation/blocs/server_list/server_list_bloc.dart';
import 'core/services/ping_service.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  try {
    // Core
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
    sl.registerLazySingleton<PingService>(() => PingService());
    
    // Initialize SharedPreferences
    if (Constants.isUseMockData) {
      SharedPreferences.setMockInitialValues({});  // For testing/initialization
    }
    final prefs = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(prefs);

    // Repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
    sl.registerLazySingleton<VpnRepository>(() => VpnRepositoryImpl(sl()));
    sl.registerLazySingleton<PremiumRepository>(() => PremiumRepositoryImpl(sl()));
    sl.registerLazySingleton<AdsRepository>(() => AdsRepositoryImpl(sl()));

    // Use cases
    sl.registerLazySingleton<RegisterDeviceUseCase>(() => RegisterDeviceUseCase(sl()));
    sl.registerLazySingleton<GetServersUseCase>(() => GetServersUseCase(sl()));
    sl.registerLazySingleton<ConnectVpnUseCase>(() => ConnectVpnUseCase(sl()));
    sl.registerLazySingleton<DisconnectVpnUseCase>(() => DisconnectVpnUseCase(sl()));
    sl.registerLazySingleton<GetPackagesUseCase>(() => GetPackagesUseCase(sl()));
    sl.registerLazySingleton<PurchasePackageUseCase>(() => PurchasePackageUseCase(sl()));
    sl.registerLazySingleton<GetPaymentHistoriesUseCase>(() => GetPaymentHistoriesUseCase(sl()));
    sl.registerLazySingleton<GetAdsUseCase>(() => GetAdsUseCase(sl()));

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
    ));

    sl.registerFactory<ServerListBloc>(() => ServerListBloc(
      sl<SharedPreferences>(),
      sl<GetServersUseCase>(),
      sl<PingService>(),
    ));

    sl.registerFactory<PremiumBloc>(() => PremiumBloc(
      getPackagesUseCase: sl<GetPackagesUseCase>(),
      purchasePackageUseCase: sl<PurchasePackageUseCase>(),
    ));

    // Onboarding bloc
    sl.registerLazySingleton<OnboardingBloc>(() => OnboardingBloc(prefs: sl<SharedPreferences>()));
  } catch (e) {
    Logger.error('Error in dependency injection: $e');
    rethrow;
  }
}