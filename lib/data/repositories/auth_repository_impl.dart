import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/device.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<MainResponse<Device>> registerDevice(String deviceId, String signature) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/user/register',
        data: {
          'device_id': deviceId,
          'signature': signature,
        },
      );
      
      return MainResponse<Device>.fromJson(
        response.data,
        (json) => Device.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('Failed to register device: ${e.message}');
    }
  }
}