import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/main_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<bool> registerDevice(String deviceId, String signature) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/register-device',
        data: {
          'device_id': deviceId,
          'signature': signature,
        },
      );
      
      final mainResponse = MainResponse.fromJson(response.data, null);
      return mainResponse.success;
    } on DioException catch (e) {
      throw Exception('Failed to register device: ${e.message}');
    }
  }
}