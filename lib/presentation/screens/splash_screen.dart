import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import '../blocs/splash/splash_bloc.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(InitializeApp());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashLoaded) {
          final vpnBloc = context.read<VpnBloc>();
          if (vpnBloc.isClosed) {
            return;
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(vpnBloc: vpnBloc),
            ),
          );
        } else if (state is SplashError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 24),
              BlocBuilder<SplashBloc, SplashState>(
                builder: (context, state) {
                  if (state is SplashLoading) {
                    return CircularProgressIndicator();
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}