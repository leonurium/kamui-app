import '../entities/ad.dart';

abstract class AdsRepository {
  Future<List<Ad>> getAds();
}