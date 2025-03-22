import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/ads_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/ad.dart';

class AdsRepositoryImpl implements AdsRepository {
  final ApiClient _apiClient;

  AdsRepositoryImpl(this._apiClient);

  @override
  Future<List<Ad>> getAds() async {
    try {
      final response = await _apiClient.dio.get('/api/ads');
      
      final mainResponse = MainResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => Ad.fromJson(e)).toList(),
      );
      
      return mainResponse.data?.cast<Ad>() ?? [];
    } on DioException catch (e) {
      throw Exception('Failed to get ads: ${e.message}');
    }
  }
}