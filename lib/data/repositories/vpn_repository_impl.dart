import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/vpn_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/server.dart';
import '../../domain/entities/session.dart';
import '../../core/utils/device_info.dart';

class VpnRepositoryImpl implements VpnRepository {
  final ApiClient _apiClient;

  VpnRepositoryImpl(this._apiClient);

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
      throw Exception('Failed to get servers: ${e.message}');
    }
  }

  @override
  Future<Session> connect(int serverId) async {
    try {
      final deviceId = await DeviceInfoUtil.getDeviceId();
      final response = await _apiClient.dio.post(
        '/api/vpn/connect',
        data: {
          'device_id': deviceId,
          'server_id': serverId,
        },
      );
      
      final mainResponse = MainResponse<Session>.fromJson(
        response.data,
        (data) => Session.fromJson(data),
      );
      
      if (!mainResponse.success || mainResponse.data == null) {
        throw Exception(mainResponse.message);
      }
      
      return mainResponse.data!;
    } on DioException catch (e) {
      throw Exception('Failed to connect: ${e.message}');
    }
  }

  @override
  Future<bool> disconnect(int sessionId) async {
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
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }
}