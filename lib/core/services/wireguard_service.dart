import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/injection.dart' as di;
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import 'package:kamui_app/core/config/constants.dart';

class WireGuardService {
  static final WireGuardService _instance = WireGuardService._internal();
  factory WireGuardService() => _instance;
  late final WireGuardFlutterInterface _wireguard;
  late final Stream<VpnStage> vpnStageSnapshot;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  WireGuardService._internal() {
    _wireguard = WireGuardFlutter.instance;
    vpnStageSnapshot = _wireguard.vpnStageSnapshot;
    _prefs = di.sl<SharedPreferences>();
  }

  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      await _wireguard.initialize(interfaceName: "wg0");
      _isInitialized = true;
      return true;
    } catch (e) {
      Logger.error('Failed to initialize WireGuard VPN: $e');
      Logger.error('Error type: ${e.runtimeType}');
      _isInitialized = false;
      return false;
    }
  }

  Future<bool> checkVpnPermission() async {
    try {
      // Initialize first to ensure we have the VPN service ready
      if (!_isInitialized) {
        await initialize();
      }

      // Try to start a test VPN connection to trigger permission request
      try {
        await _wireguard.startVpn(
          serverAddress: "127.0.0.1",
          wgQuickConfig: "[Interface]\nPrivateKey = test\nAddress = 10.0.0.1/24\n[Peer]\nPublicKey = test\nAllowedIPs = 0.0.0.0/0",
          providerBundleIdentifier: Constants.vpnProviderBundleId,
        );
        // If we get here, permissions were granted
        await _wireguard.stopVpn();
        return true;
      } catch (e) {
        if (e.toString().contains('Permissions are not given')) {
          Logger.error('VPN permissions not granted');
          return false;
        }
        // If we get any other error, it means permissions were granted but the test connection failed
        // which is expected since we used dummy config
        return true;
      }
    } catch (e) {
      Logger.error('Error checking VPN permission: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<void> connect(ConnectionData connectionData) async {
    try {
      // First ensure we're initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Save session data to SharedPreferences
      final sessionJson = jsonEncode(connectionData.toJson());
      String config = _buildWireGuardConfig(connectionData);
      
      await _wireguard.startVpn(
        serverAddress: connectionData.session.endpoint,
        wgQuickConfig: config,
        providerBundleIdentifier: Constants.vpnProviderBundleId,
      );
      await _prefs.setString('current_connection_data', sessionJson);
      
    } catch (e) {
      Logger.error('WireGuard connection error: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      
      if (e.toString().contains('IPC failed')) {
        // Try to reinitialize on IPC failure
        _isInitialized = false;
        await initialize();
        // Retry the connection
        await connect(connectionData);
      } else {
        rethrow;
      }
    }
  }

  Future<void> disconnect() async {
    try {
      if (_isInitialized) {
        await _wireguard.stopVpn();
        await _prefs.remove('current_connection_data');
        _isInitialized = false;
      }
    } catch (e) {
      Logger.error('WireGuard disconnection error: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<bool> isConnected() async {
    try {
      final isConnected = await _wireguard.isConnected();
      return isConnected;
    } catch (e) {
      Logger.error('Error checking WireGuard connection status: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  String _buildWireGuardConfig(ConnectionData connectionData) {
    String config = '[Interface]';
    config += '\nPrivateKey = ${connectionData.session.privateKey}';
    config += '\nAddress = ${connectionData.session.ipAddress}';
    config += '\nDNS = ${connectionData.pool.dns}';
    config += '\nMTU = 1420'; // Add MTU for better performance
    config += '\n[Peer]';
    config += '\nPublicKey = ${connectionData.pool.publicKey}';
    config += '\nAllowedIPs = ${connectionData.pool.allowedIps}';
    config += '\nPersistentKeepalive = ${connectionData.pool.persistentKeepalive}';
    config += '\nEndpoint = ${connectionData.session.endpoint}:${connectionData.session.listenPort}';

    if (connectionData.pool.presharedKey.trim().isNotEmpty) {
      config += '\nPresharedKey = ${connectionData.pool.presharedKey}';
    }

    return config;
  }
} 