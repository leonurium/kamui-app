import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../blocs/splash/splash_bloc.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _getVersion();
    context.read<SplashBloc>().add(InitializeApp());
  }

  Future<void> _getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version}';
    });
  }

  void _showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Unable to connect to the server. This might be due to VPN blocking internet access. Please close the app and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close App'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
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
        } else if (state is SplashTimeoutError) {
          _showTimeoutDialog(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
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
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _version ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}