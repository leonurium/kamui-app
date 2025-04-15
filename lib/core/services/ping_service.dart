import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:kamui_app/domain/entities/ping_result.dart';

class PingService {
  static const int _timeoutSeconds = 5;
  static const int _downloadSize = 1000000; // 1MB

  Future<PingResult> pingServer(String serverUrl) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Try to download a small file to measure speed
      final response = await http.get(
        Uri.parse('$serverUrl/ping'),
        headers: {'Accept': 'application/octet-stream'},
      ).timeout(const Duration(seconds: _timeoutSeconds));

      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final downloadTime = stopwatch.elapsedMilliseconds / 1000; // Convert to seconds
        final mbps = (_downloadSize * 8) / (downloadTime * 1000000); // Convert to Mbps
        
        return PingResult(
          serverId: 0, // Will be set by the caller
          mbps: mbps,
          latency: stopwatch.elapsedMilliseconds,
          isOnline: true,
        );
      } else {
        return PingResult(
          serverId: 0,
          mbps: 0,
          latency: 0,
          isOnline: false,
        );
      }
    } on TimeoutException {
      return PingResult(
        serverId: 0,
        mbps: 0,
        latency: 0,
        isOnline: false,
      );
    } catch (e) {
      return PingResult(
        serverId: 0,
        mbps: 0,
        latency: 0,
        isOnline: false,
      );
    }
  }
} 