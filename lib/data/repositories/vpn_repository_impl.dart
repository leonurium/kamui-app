import 'package:dio/dio.dart';
import 'package:kamui_app/core/config/constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/vpn_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/server.dart';
import '../../domain/entities/session.dart';
import '../../core/utils/device_info.dart';
import '../../core/utils/logger.dart';
import 'vpn_repository_mock.dart';

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
      
      return mainResponse.data?.cast<Server>() ?? [];
    } on DioException catch (e) {
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
  Future<Session> connect(int serverId) async {
    try {
      Logger.info('VpnRepository: Connecting to VPN with serverId: $serverId');
      final deviceId = await DeviceInfoUtil.getDeviceId();
      Logger.info('VpnRepository: Device ID: $deviceId');
      
      final response = await _apiClient.dio.post(
        '/api/vpn/connect',
        data: {
          'device_id': deviceId,
          'server_id': serverId,
        },
      );
      
      Logger.info('VpnRepository: API response: ${response.data}');
      
      final mainResponse = MainResponse<Session>.fromJson(
        response.data,
        (data) => Session.fromJson(data),
      );
      
      if (!mainResponse.success || mainResponse.data == null) {
        Logger.error('VpnRepository: API error: ${mainResponse.message}');
        throw Exception(mainResponse.message);
      }
      
      Logger.info('VpnRepository: Successfully connected to VPN');
      return mainResponse.data!;
    } on DioException catch (e) {
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.connect(serverId);
      }
      Logger.error('VpnRepository: Failed to connect to VPN: ${e.message}');
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
      return mainResponse.success;
    } on DioException catch (e) {
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