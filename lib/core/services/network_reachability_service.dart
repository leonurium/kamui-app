import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:kamui_app/core/utils/logger.dart';

class NetworkReachabilityService {
  final _controller = StreamController<bool>.broadcast();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  Stream<bool> get reachabilityStream => _controller.stream;

  NetworkReachabilityService() {
    Logger.info('NetworkReachabilityService initialized');
  }

  void startMonitoring() {
    if (_isMonitoring) {
      Logger.warning('Monitoring already active');
      return;
    }

    Logger.info('Starting network monitoring');
    _isMonitoring = true;
    _checkReachability();
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkReachability(),
    );
  }

  void stopMonitoring() {
    if (!_isMonitoring) {
      Logger.warning('Monitoring not active');
      return;
    }

    Logger.info('Stopping network monitoring');
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }

  Future<void> _checkReachability() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      
      final isReachable = response.statusCode == 200;
      Logger.info('Network reachability check: ${isReachable ? "Connected" : "Disconnected"}');
      _controller.add(isReachable);
    } catch (e) {
      Logger.error('Network unreachable: $e');
      _controller.add(false);
    }
  }

  void dispose() {
    Logger.info('Disposing NetworkReachabilityService');
    stopMonitoring();
    _controller.close();
  }
} 