import 'package:kamui_app/domain/entities/ad.dart';
import 'package:kamui_app/domain/repositories/ads_repository.dart';

class AdsRepositoryMock implements AdsRepository {
  @override
  Future<List<Ad>> getAds() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    return [
      Ad(
        id: 1,
        title: 'Special Offer!',
        mediaType: 'image',
        mediaUrl: 'https://picsum.photos/400/600',
        clickUrl: 'https://example.com/special-offer',
        countdown: 5,
        isAutoClicked: false,
      ),
      Ad(
        id: 2,
        title: 'New Features Available',
        mediaType: 'video',
        mediaUrl: 'https://example.com/video.mp4',
        clickUrl: 'https://example.com/new-features',
        countdown: 10,
        isAutoClicked: false,
      ),
      Ad(
        id: 3,
        title: 'Upgrade to Premium',
        mediaType: 'image',
        mediaUrl: 'https://picsum.photos/400/600',
        clickUrl: 'https://example.com/upgrade',
        countdown: 8,
        isAutoClicked: false,
      ),
    ];
  }
} 