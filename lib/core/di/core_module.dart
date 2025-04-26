import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/network/api_client.dart';
import 'package:kamui_app/core/services/ping_service.dart';
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/core/utils/logger.dart';

Future<void> initCoreModule(GetIt sl) async {
  try {
    // Core services
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
    sl.registerLazySingleton<PingService>(() => PingService());
    sl.registerLazySingleton<WireGuardService>(() => WireGuardService());
  } catch (e) {
    Logger.error('Error in core module initialization: $e');
    rethrow;
  }
} 