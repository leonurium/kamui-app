import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/ads_repository.dart';
import '../models/main_response.dart';
import '../../domain/entities/ad.dart';
import 'ads_repository_mock.dart';

class AdsRepositoryImpl implements AdsRepository {
  final ApiClient _apiClient;
  final AdsRepositoryMock _mockRepository;

  AdsRepositoryImpl(this._apiClient) : _mockRepository = AdsRepositoryMock();

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
      // If server is down or timeout, use mock data
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _mockRepository.getAds();
      }
      throw Exception('Failed to get ads: ${e.message}');
    }
  }
}