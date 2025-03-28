import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/ad.dart';

class AdsOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const AdsOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  State<AdsOverlay> createState() => _AdsOverlayState();
}

class _AdsOverlayState extends State<AdsOverlay> {
  Ad? currentAd;
  int countdown = 0;
  VideoPlayerController? _videoController;
  bool canClose = false;

  @override
  void initState() {
    super.initState();
    _loadRandomAd();
  }

  Future<void> _loadRandomAd() async {
    final prefs = await SharedPreferences.getInstance();
    final adsJson = prefs.getString('ads');
    if (adsJson != null) {
      final List<dynamic> adsList = jsonDecode(adsJson);
      final ads = adsList.map((json) => Ad.fromJson(json)).toList();
      if (ads.isNotEmpty) {
        // final List<Ad> mockAds = [
        //   Ad(
        //     id: 1,
        //     title: "Watch Video to Get 1 Hour Free",
        //     mediaType: "video",
        //     // Using a smaller video file
        //     mediaUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        //     clickUrl: "https://example.com/promo",
        //     countdown: 30,
        //   ),
        //   Ad(
        //     id: 2,
        //     title: "Special VPN Offer - 50% OFF",
        //     mediaType: "image",
        //     // Using smaller image dimensions
        //     mediaUrl: "https://picsum.photos/400/600",
        //     clickUrl: "https://example.com/offer",
        //     countdown: 10,
        //   ),
        // ];
        // mockAds.shuffle();
        ads.shuffle();
        setState(() {
          currentAd = ads.first;
          countdown = currentAd?.countdown ?? 10;
        });
        if (currentAd?.mediaType == 'video') {
          _initializeVideo();
        }
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && countdown > 0) {
        setState(() {
          countdown--;
          if (countdown == 0) {
            canClose = true;
          }
        });
        _startCountdown();
      }
    });
  }

  bool _isVideoLoading = false;

  void _initializeVideo() {
    final ad = currentAd;
    if (ad == null) return;
    
    setState(() {
      _isVideoLoading = true;
    });

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(ad.mediaUrl)
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
          });
          _videoController?.play();
          _videoController?.setLooping(true);
        }
      }).catchError((error) {
        Logger.error("Failed to load video: $error");
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
            currentAd = Ad(
              id: ad.id,
              title: "Unable to load video",
              mediaType: "image",
              mediaUrl: "https://picsum.photos/seed/vpn/1080/1920",
              clickUrl: ad.clickUrl,
              countdown: ad.countdown,
            );
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final ad = currentAd;
    if (ad == null) return const SizedBox();

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ad.mediaType == 'video')
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_videoController?.value.isInitialized == true)
                    AspectRatio(
                      aspectRatio: _videoController?.value.aspectRatio ?? 16/9,
                      child: VideoPlayer(_videoController!),
                    ),
                  if (_isVideoLoading || _videoController?.value.isBuffering == true)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          _isVideoLoading ? 'Loading video...' : 'Buffering...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                ],
              )
            else if (ad.mediaType == 'image')
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    ad.mediaUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading image...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      Logger.error("Failed to load image: $error");
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  ad.mediaUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    Logger.error("Failed to load image: $error");
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              top: 40,
              right: 16,
              child: Column(
                children: [
                  Text(
                    '$countdown',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (canClose)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _videoController?.pause();
                        widget.onClose();
                      },
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (currentAd?.clickUrl != null) {
                      // Handle URL click
                    }
                  },
                  child: Text(
                    currentAd?.title ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}