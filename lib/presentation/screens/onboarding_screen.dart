import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:kamui_app/presentation/screens/home_page.dart';
import 'package:kamui_app/injection.dart' as di;
import 'package:kamui_app/core/services/wireguard_service.dart';
import 'package:kamui_app/presentation/blocs/vpn/vpn_bloc.dart';
import 'package:kamui_app/core/utils/doodle_ipsum_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final WireGuardService _wireguardService = di.sl<WireGuardService>();
  bool _hasAcceptedPrivacyPolicy = false;
  bool _hasGrantedVpnPermission = false;
  bool _isInitializing = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Gama VPN',
      description: 'The internet was built for stationary computers, but today we\'re always on the move. Gama VPN replaces outdated connections with a modern, optimized protocol that keeps you secure and fast, wherever you are.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'welcome',
        isRandom: false,
      ),
    ),
    OnboardingPage(
      title: 'Privacy Policy',
      description: 'Please review our privacy policy and terms of service before continuing.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'privacy',
        isRandom: false,
      ),
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
    ),
    OnboardingPage(
      title: 'Ready to Start',
      description: 'You\'re all set! Let\'s get started with Gama VPN.',
      image: DoodleIpsumUtils.getImageUrl(
        width: 500,
        height: 500,
        category: 'flat',
        seed: 'start',
        isRandom: false,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestVpnPermission() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      final hasPermission = await _wireguardService.checkVpnPermission();
      
      setState(() {
        _hasGrantedVpnPermission = hasPermission;
        _isInitializing = false;
      });

      if (hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VPN permission has been granted. Click continue to proceed.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
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
    } catch (e) {
      Logger.error('Error requesting VPN permission: $e');
      setState(() {
        _isInitializing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request VPN permission. Please try again.'),
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
      if (_currentPage == 1) {
        if (!_hasAcceptedPrivacyPolicy) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You must accept the privacy policy to continue.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } else if (_currentPage == 2) {
        if (!_hasGrantedVpnPermission) {
          _requestVpnPermission();
          return;
        }
      }
      
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Save onboarding completed state
      context.read<OnboardingBloc>().add(CompleteOnboarding());
    }
  }

  Widget _buildPrivacyPolicyPage() {
    return Container(
      padding: EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: WebViewWidget(
            controller: WebViewController()
              ..loadRequest(Uri.parse('https://getlorem.com/privacy-policy'))
              ..setJavaScriptMode(JavaScriptMode.unrestricted),
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasAcceptedPrivacyPolicy = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You must accept the privacy policy to continue.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasAcceptedPrivacyPolicy = true;
                    });
                    _onNextPressed();
                  },
                  child: Text('Accept'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton() {
    if (_currentPage == 1) {
      return SizedBox(height: 40); // Hide button on privacy policy page
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _isInitializing ? null : _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 26, 48, 85),
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isInitializing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _currentPage == _pages.length - 1 
                    ? 'Start' 
                    : _currentPage == 2 
                        ? 'Grant Permission' 
                        : 'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
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
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                if (index == 1) {
                  return _buildPrivacyPolicyPage();
                }
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
                              ? Color.fromARGB(255, 26, 48, 85)
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildNavigationButton(),
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

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image
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
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 