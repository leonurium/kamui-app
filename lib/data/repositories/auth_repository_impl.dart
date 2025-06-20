import 'package:dio/dio.dart';
import 'package:kamui_app/core/config/constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/device.dart';
import 'auth_repository_mock.dart';
import 'package:kamui_app/core/services/analytics_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final AuthRepositoryMock _mockRepository;

  AuthRepositoryImpl(this._apiClient) : _mockRepository = AuthRepositoryMock();

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
      
      final mainResponse = MainResponse<Device>.fromJson(
        response.data,
        (json) => Device.fromJson(json as Map<String, dynamic>),
      );
      await AnalyticsService.logFeatureUsage(
        featureName: 'registerDevice',
        action: 'api_response',
        additionalParams: {
          'success': mainResponse.success,
          'message': mainResponse.message ?? '',
          'error': mainResponse.error ?? '',
        },
      );
      return mainResponse;
    } on DioException catch (e) {
      await AnalyticsService.logFeatureUsage(
        featureName: 'registerDevice',
        action: 'api_error',
        additionalParams: {
          'error': e.message ?? '',
        },
      );
      // If server is down or timeout, use mock data
      if (Constants.isUseMockData) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          return _mockRepository.registerDevice(deviceId, signature);
        }
      }
      throw Exception('Failed to register device: ${e.message}');
    }
  }
}