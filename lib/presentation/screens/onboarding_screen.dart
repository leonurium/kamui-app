import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:kamui_app/presentation/screens/home_page.dart';
import 'package:kamui_app/injection.dart' as di;
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/core/utils/doodle_ipsum_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Gama VPN',
      description: 'Secure your internet connection and protect your privacy with our fast and reliable VPN service.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'welcome',
        isRandom: false,
      ),
      color: Color.fromRGBO(37, 112, 252, 1),
    ),
    OnboardingPage(
      title: 'Privacy Policy',
      description: 'We respect your privacy. Our service is designed to protect your data and keep your online activities private.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'privacy',
        isRandom: false,
      ),
      color: Color.fromRGBO(37, 112, 252, 1),
    ),
    OnboardingPage(
      title: 'VPN Permission',
      description: 'To establish a secure connection, we need to create a VPN profile on your device.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'vpn',
        isRandom: false,
      ),
      color: Color.fromRGBO(37, 112, 252, 1),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestVpnPermission() async {
    try {
      await _wireguard.initialize(interfaceName: "wg0");
      // Permission granted, proceed to complete onboarding
      context.read<OnboardingBloc>().add(CompleteOnboarding());
    } catch (e) {
      Logger.error(e.toString());
      // Show more detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VPN permission is required. Please make sure you have granted VPN permissions in your device settings.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _requestVpnPermission,
          ),
        ),
      );
    }
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _requestVpnPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(vpnBloc: di.sl<VpnBloc>()),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPageView(page: _pages[index]);
              },
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? _pages[index].color
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Grant Permission' : 'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageView({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DoodleIpsumUtils.getImage(
            page.image,
            width: 300,
            height: 300,
          ),
          SizedBox(height: 40),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 