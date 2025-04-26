import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/data/repositories/auth_repository_impl.dart';
import 'package:kamui_app/data/repositories/vpn_repository_impl.dart';
import 'package:kamui_app/data/repositories/premium_repository_impl.dart';
import 'package:kamui_app/data/repositories/ads_repository_impl.dart';
import 'package:kamui_app/domain/repositories/auth_repository.dart';
import 'package:kamui_app/domain/repositories/vpn_repository.dart';
import 'package:kamui_app/domain/repositories/premium_repository.dart';
import 'package:kamui_app/domain/repositories/ads_repository.dart';

Future<void> initRepositoryModule(GetIt sl) async {
  try {
    // Repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
    sl.registerLazySingleton<VpnRepository>(() => VpnRepositoryImpl(sl()));
    sl.registerLazySingleton<PremiumRepository>(() => PremiumRepositoryImpl(sl()));
    sl.registerLazySingleton<AdsRepository>(() => AdsRepositoryImpl(sl()));
  } catch (e) {
    Logger.error('Error in repository module initialization: $e');
    rethrow;
  }
} 