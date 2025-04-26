import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/usecases/register_device_usecase.dart';
import 'package:kamui_app/domain/usecases/get_servers_usecase.dart';
import 'package:kamui_app/domain/usecases/connect_vpn_usecase.dart';
import 'package:kamui_app/domain/usecases/disconnect_vpn_usecase.dart';
import 'package:kamui_app/domain/usecases/get_packages_usecase.dart';
import 'package:kamui_app/domain/usecases/purchase_package_usecase.dart';
import 'package:kamui_app/domain/usecases/get_payment_histories_usecase.dart';
import 'package:kamui_app/domain/usecases/get_ads_usecase.dart';

Future<void> initUseCaseModule(GetIt sl) async {
  try {
    // Use cases
    sl.registerLazySingleton<RegisterDeviceUseCase>(() => RegisterDeviceUseCase(sl()));
    sl.registerLazySingleton<GetServersUseCase>(() => GetServersUseCase(sl()));
    sl.registerLazySingleton<ConnectVpnUseCase>(() => ConnectVpnUseCase(sl()));
    sl.registerLazySingleton<DisconnectVpnUseCase>(() => DisconnectVpnUseCase(sl()));
    sl.registerLazySingleton<GetPackagesUseCase>(() => GetPackagesUseCase(sl()));
    sl.registerLazySingleton<PurchasePackageUseCase>(() => PurchasePackageUseCase(sl()));
    sl.registerLazySingleton<GetPaymentHistoriesUseCase>(() => GetPaymentHistoriesUseCase(sl()));
    sl.registerLazySingleton<GetAdsUseCase>(() => GetAdsUseCase(sl()));
  } catch (e) {
    Logger.error('Error in use case module initialization: $e');
    rethrow;
  }
} 