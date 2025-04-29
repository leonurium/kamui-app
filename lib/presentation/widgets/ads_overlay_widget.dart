import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/ad.dart';

class AdsOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const AdsOverlay({super.key, required this.onClose});

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
    final adsJson = prefs.getString('ads_interstitial');
    if (adsJson != null) {
      final List<dynamic> adsList = jsonDecode(adsJson);
      final ads = adsList.map((json) => Ad.fromJson(json)).toList();
      if (ads.isNotEmpty) {
        ads.shuffle();
        setState(() {
          currentAd = ads.first;
          countdown = currentAd?.countdown ?? 10;
        });
        if (currentAd?.mediaType == 'video') {
          _initializeVideo();
        }
        _startCountdown();
      } else {
        // If no ads available, close the overlay immediately
        widget.onClose();
      }
    } else {
      // If no ads data in preferences, close the overlay immediately
      widget.onClose();
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && countdown > 0) {
        setState(() {
          countdown--;
          // Check if we should auto-click at 50% of the original countdown
          if (currentAd?.isAutoClicked == true && 
              countdown == ((currentAd?.countdown ?? 10) ~/ 2)) {
            _launchUrl();
          }
          if (countdown == 0) {
            canClose = true;
          }
        });
        _startCountdown();
      }
    });
  }

  bool _isVideoLoading = false;

  void _initializeVideo() async {
    final ad = currentAd;
    if (ad == null) return;

    setState(() {
      _isVideoLoading = true;
    });

    try {
      final uri = Uri.parse(ad.mediaUrl);
      if (!uri.isAbsolute) {
        throw Exception('Invalid video URL');
      }

      // Dispose any existing controller
      await _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(uri);

      await _videoController?.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
        _videoController?.play();
        _videoController?.setLooping(true);
      }
    } catch (error) {
      Logger.error("Failed to load video: $error");
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          // Fallback to image if video fails to load
          currentAd = Ad(
            id: ad.id,
            title: ad.title,
            mediaType: "image",
            mediaUrl: "https://picsum.photos/400/600",
            clickUrl: ad.clickUrl,
            countdown: ad.countdown,
            isAutoClicked: ad.isAutoClicked,
          );
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    final url = currentAd?.clickUrl;
    if (url != null) {
      try {
        final uri = Uri.parse(url);
        if (!uri.isAbsolute) {
          Logger.error("Invalid URL format: $url");
          return;
        }

        final canLaunch = await canLaunchUrl(uri);
        if (!canLaunch) {
          Logger.error("Could not launch URL: $url");
          return;
        }

        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } catch (e) {
        Logger.error("Error launching URL: $e");
      }
    }
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
            GestureDetector(
              onTap: _launchUrl,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ad.mediaType == 'video')
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_videoController?.value.isInitialized == true)
                          Center(
                            child: AspectRatio(
                              aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        if (_isVideoLoading ||
                            _videoController?.value.isBuffering == true)
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
                                Icon(Icons.error_outline,
                                    color: Colors.white, size: 48),
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
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Column(
                children: [
                  if (!canClose)
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
              bottom: 80,
              right: 20,
              child: ElevatedButton(
                onPressed: _launchUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4), // Google Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  elevation: 0,
                  shadowColor: Colors.black.withValues(alpha: .2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _launchUrl,
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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}
