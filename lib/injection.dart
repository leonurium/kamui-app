// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import modules
import 'core/di/core_module.dart';
import 'core/di/repository_module.dart';
import 'core/di/usecase_module.dart';
import 'core/di/bloc_module.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // Initialize SharedPreferences
    if (Constants.isUseMockData) {
      SharedPreferences.setMockInitialValues({});  // For testing/initialization
    }
    final prefs = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(prefs);

    // Initialize modules
    await initCoreModule(sl);
    await initRepositoryModule(sl);
    await initUseCaseModule(sl);
    await initBlocModule(sl);
  } catch (e) {
    Logger.error('Error in dependency injection: $e');
    rethrow;
  }
}