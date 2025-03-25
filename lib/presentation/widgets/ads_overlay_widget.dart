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
        final List<Ad> mockAds = [
          Ad(
            id: 1,
            title: "Watch Video to Get 1 Hour Free",
            mediaType: "video",
            mediaUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            clickUrl: "https://example.com/promo",
            countdown: 30,
          ),
          Ad(
            id: 2,
            title: "Special VPN Offer - 50% OFF",
            mediaType: "image",
            mediaUrl: "https://picsum.photos/1080/1920",
            clickUrl: "https://example.com/offer",
            countdown: 10,
          ),
        ];
        mockAds.shuffle();
        ads.shuffle();
        setState(() {
          currentAd = mockAds.first;
          countdown = currentAd?.countdown ?? 10;
        });
        if (currentAd?.mediaType == 'video') {
          _initializeVideo();
        }
        _startCountdown();
      }
    }
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(currentAd!.mediaUrl)
    )..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentAd == null) return const SizedBox();

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (currentAd?.mediaType == 'video' && _videoController?.value.isInitialized == true)
              VideoPlayer(_videoController!)
            else if (currentAd?.mediaType == 'image')
              Image.network(
                currentAd!.mediaUrl,
                fit: BoxFit.contain,
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