import 'package:flutter/material.dart';

class DoodleIpsumUtils {
  static const String _baseUrl = 'https://doodleipsum.com';
  
  static String getImageUrl({
    required int width,
    required int height,
    String? category,
    String? seed,
    bool isRandom = true,
  }) {
    final String dimensions = '${width}x$height';
    final String categoryPath = category != null ? '/$category' : '';
    final String seedParam = seed != null ? '?seed=$seed' : '';
    final String randomParam = isRandom ? '?random=${DateTime.now().millisecondsSinceEpoch}' : '';
    
    return '$_baseUrl/$dimensions$categoryPath${seed != null ? seedParam : randomParam}';
  }

  static Widget getImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline),
        );
      },
    );
  }
} 