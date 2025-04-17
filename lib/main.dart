import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/splash/splash_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:kamui_app/core/utils/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kamui_app/core/services/analytics_service.dart';
import 'injection.dart' as di;
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    await Firebase.initializeApp();
    await di.init();
    
    // Set initial user properties
    await AnalyticsService.setUserProperties(
      subscriptionStatus: 'free',
      connectionType: 'mobile',
      deviceType: 'android', // You might want to detect this dynamically
    );
    
    runApp(const App());
  } catch (e, stackTrace) {
    // Log the crash
    AnalyticsService.logAppCrash(
      error: e.toString(),
      stackTrace: stackTrace.toString(),
      screenName: 'main',
    );
    
    debugPrint('Error during initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Get a single instance of VpnBloc
    final vpnBloc = di.sl<VpnBloc>();

    return MaterialApp(
      title: 'Gama VPN',
      debugShowCheckedModeBanner: false,
      theme: customLightTheme(context),
      darkTheme: customDarkTheme(context),
      themeMode: ThemeMode.system,
      navigatorObservers: [AnalyticsService.observer],
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final bloc = di.sl<SplashBloc>();
              return bloc;
            },
          ),
          BlocProvider.value(
            value: vpnBloc,
          ),
          BlocProvider(
            create: (context) {
              final bloc = di.sl<OnboardingBloc>();
              bloc.add(CheckOnboardingStatus());
              return bloc;
            },
          ),
        ],
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnboardingNotCompleted) {
              AnalyticsService.setCurrentScreen('OnboardingScreen');
              return OnboardingScreen();
            }
            AnalyticsService.setCurrentScreen('SplashScreen');
            return SplashScreen();
          },
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please restart the app. If the problem persists, please contact support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Error details: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}