import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/premium_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/package.dart';
import '../../domain/entities/payment_history.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final ApiClient _apiClient;

  PremiumRepositoryImpl(this._apiClient);

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
      throw Exception('Failed to get payment histories: ${e.message}');
    }
  }
}