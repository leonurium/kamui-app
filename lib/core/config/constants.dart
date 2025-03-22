import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Private constructor to prevent instantiation
  Constants._();
  
  static String get secretKey => dotenv.env['SECRET_KEY'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}