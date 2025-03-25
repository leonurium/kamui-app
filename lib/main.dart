import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/splash/splash_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/presentation/screens/home_page.dart';
import 'package:kamui_app/core/utils/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection.dart' as di;
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await dotenv.load();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gama VPN',
      debugShowCheckedModeBanner: false,
      theme: customLightTheme(context),
      darkTheme: customDarkTheme(context),
      themeMode: ThemeMode.system,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di.sl<SplashBloc>(),
          ),
          BlocProvider(
            create: (context) => di.sl<VpnBloc>(),
          ),
        ],
        child: SplashScreen(),
      ),
    );
  }
}
