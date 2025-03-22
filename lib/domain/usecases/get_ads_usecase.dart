import '../entities/ad.dart';
import '../repositories/ads_repository.dart';

class GetAdsUseCase {
  final AdsRepository repository;

  GetAdsUseCase(this.repository);

  Future<List<Ad>> execute() {
    return repository.getAds();
  }
}