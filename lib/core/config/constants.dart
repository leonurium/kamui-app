import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class Constants {
  // Private constructor to prevent instantiation
  Constants._();
  
  static String get secretKey => dotenv.env['SECRET_KEY'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static bool get networkLogger => dotenv.env['NETWORK_LOGGER'] == 'true';
  static bool get isUseMockData => dotenv.env['USE_MOCK_DATA'] == 'true';
  static bool get forceBlockAds => dotenv.env['FORCE_BLOCK_ADS'] == 'true';

  static const String faqUrl = 'https://gama-vpn.com/#faq';
  
  static String get vpnProviderBundleId {
    if (Platform.isAndroid) {
      return 'com.gamavpn.app.vpn';
    } else if (Platform.isIOS) {
      return 'com.gamavpn.ios.vpn';
    }
    throw UnsupportedError('Unsupported platform');
  }
}