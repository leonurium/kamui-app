import 'package:dio/dio.dart';
import 'package:kamui_app/core/config/constants.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/core/network/api_client.dart';
import 'package:kamui_app/domain/repositories/vpn_repository.dart';
import 'package:kamui_app/data/models/main_response.dart';
import 'package:kamui_app/domain/entities/server.dart';
import 'package:kamui_app/core/utils/device_info.dart';
import 'vpn_repository_mock.dart';
import 'package:kamui_app/core/services/analytics_service.dart';

class VpnRepositoryImpl implements VpnRepository {
  final ApiClient _apiClient;
  final VpnRepositoryMock _mockRepository;

  VpnRepositoryImpl(this._apiClient) : _mockRepository = VpnRepositoryMock();

  @override
  Future<List<Server>> getServers() async {
    try {
      final response = await _apiClient.dio.get('/api/vpn/servers');
      
      final mainResponse = MainResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => Server.fromJson(e)).toList(),
      );
      
      await AnalyticsService.logFeatureUsage(
        featureName: 'getServers',
        action: 'api_response',
        additionalParams: {
          'success': mainResponse.success,
          'message': mainResponse.message ?? '',
          'error': mainResponse.error ?? '',
        },
      );
      
      return mainResponse.data?.cast<Server>() ?? [];
    } on DioException catch (e) {
      await AnalyticsService.logFeatureUsage(
        featureName: 'getServers',
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
          return _mockRepository.getServers();
        }
      }
      throw Exception('Failed to get servers: ${e.message}');
    }
  }

  @override
  Future<ConnectionData> connect(int serverId) async {
    try {
      final deviceId = await DeviceInfoUtil.getDeviceId();      
      final response = await _apiClient.dio.post(
        '/api/vpn/connect',
        data: {
          'device_id': deviceId,
          'server_id': serverId,
        },
      );
            
      final mainResponse = MainResponse<ConnectionData>.fromJson(
        response.data,
        (data) => ConnectionData.fromJson(data),
      );
      
      await AnalyticsService.logFeatureUsage(
        featureName: 'connect',
        action: 'api_response',
        additionalParams: {
          'success': mainResponse.success,
          'message': mainResponse.message ?? '',
          'error': mainResponse.error ?? '',
        },
      );
      
      if (!mainResponse.success || mainResponse.data == null) {
        throw Exception(mainResponse.message);
      }
      
      return mainResponse.data!;
    } on DioException catch (e) {
      await AnalyticsService.logFeatureUsage(
        featureName: 'connect',
        action: 'api_error',
        additionalParams: {
          'error': e.message ?? '',
        },
      );
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.connect(serverId);
      }
      throw Exception('Failed to connect: ${e.message}');
    }
  }

  @override
  Future<bool> disconnect(String sessionId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/vpn/disconnect',
        data: {
          'session_id': sessionId,
        },
      );
      
      final mainResponse = MainResponse.fromJson(response.data, null);
      await AnalyticsService.logFeatureUsage(
        featureName: 'disconnect',
        action: 'api_response',
        additionalParams: {
          'success': mainResponse.success,
          'message': mainResponse.message ?? '',
          'error': mainResponse.error ?? '',
        },
      );
      return mainResponse.success;
    } on DioException catch (e) {
      await AnalyticsService.logFeatureUsage(
        featureName: 'disconnect',
        action: 'api_error',
        additionalParams: {
          'error': e.message ?? '',
        },
      );
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.disconnect(sessionId);
      }
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }
}