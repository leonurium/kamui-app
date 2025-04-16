import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:kamui_app/core/utils/logger.dart';
import 'package:kamui_app/domain/entities/connection_data.dart';
import 'package:kamui_app/injection.dart' as di;
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';

class WireGuardService {
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;
  late SharedPreferences _prefs;

  WireGuardService() {
    _prefs = di.sl<SharedPreferences>();
  }

  Future<bool> initialize() async {
    try {
      Logger.info('Initializing WireGuard VPN...');
      await _wireguard.initialize(interfaceName: "wg0");
      Logger.info('WireGuard VPN initialized successfully');
      return true;
    } catch (e) {
      Logger.error('Failed to initialize WireGuard VPN: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> checkVpnPermission() async {
    try {
      await _wireguard.initialize(interfaceName: "wg0");
      return true;
    } catch (e) {
      Logger.error('Error checking VPN permission: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<void> connect(ConnectionData connectionData) async {
    try {
      // Save session data to SharedPreferences
      final sessionJson = jsonEncode(connectionData.toJson());
      await _prefs.setString('current_connection_data', sessionJson);
      Logger.info('Current Connection data saved to SharedPreferences');

      String config = _buildWireGuardConfig(connectionData);
      Logger.info('Starting WireGuard VPN with config: $config');
      
      await _wireguard.startVpn(
        serverAddress: connectionData.session.endpoint,
        wgQuickConfig: config,
        providerBundleIdentifier: 'com.gamavpn.app',
      );
      
      Logger.info('WireGuard VPN started successfully');
    } catch (e) {
      Logger.error('WireGuard connection error: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await _wireguard.stopVpn();
      await _prefs.remove('current_connection_data');
      Logger.info('WireGuard VPN stopped successfully');
    } catch (e) {
      Logger.error('WireGuard disconnection error: $e');
      Logger.error('Error type: ${e.runtimeType}');
      Logger.error('Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  String _buildWireGuardConfig(ConnectionData connectionData) {
    String config = '[Interface]';
    config += '\nPrivateKey = ${connectionData.session.privateKey}';
    config += '\nAddress = ${connectionData.session.ipAddress}';
    config += '\nDNS = ${connectionData.pool.dns}';
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