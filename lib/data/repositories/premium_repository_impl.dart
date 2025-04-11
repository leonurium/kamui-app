import 'package:dio/dio.dart';
import 'package:kamui_app/core/config/constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/premium_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/package.dart';
import '../../domain/entities/payment_history.dart';
import 'premium_repository_mock.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final ApiClient _apiClient;
  final PremiumRepositoryMock _mockRepository;

  PremiumRepositoryImpl(this._apiClient) : _mockRepository = PremiumRepositoryMock();

  @override
  Future<List<Package>> getPackages() async {
    try {
      final response = await _apiClient.dio.get('/api/packages');
      
      final mainResponse = MainResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => Package.fromJson(e)).toList(),
      );
      
      return mainResponse.data?.cast<Package>() ?? [];
    } on DioException catch (e) {
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.getPackages();
      }
      throw Exception('Failed to get packages: ${e.message}');
    }
  }

  @override
  Future<bool> purchasePackage(int packageId, String purchaseToken, String platform) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/payment',
        data: {
          'package_id': packageId,
          'purchase_token': purchaseToken,
          'platform': platform,
        },
      );
      
      final mainResponse = MainResponse.fromJson(response.data, null);
      return mainResponse.success;
    } on DioException catch (e) {
      // If server is down or timeout, use mock data
      if (Constants.isUseMockData) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          return _mockRepository.purchasePackage(packageId, purchaseToken, platform);
        }
      }
      throw Exception('Failed to purchase package: ${e.message}');
    }
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistories() async {
    try {
      final response = await _apiClient.dio.get('/api/payment/histories');
      
      final mainResponse = MainResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => PaymentHistory.fromJson(e)).toList(),
      );
      
      return mainResponse.data?.cast<PaymentHistory>() ?? [];
    } on DioException catch (e) {
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.getPaymentHistories();
      }
      throw Exception('Failed to get payment histories: ${e.message}');
    }
  }
}