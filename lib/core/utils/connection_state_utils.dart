import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

class ConnectionStateUtils {
  static String getConnectionState(VpnStage? state) {
    switch (state) {
      case VpnStage.connected:
        return 'Connected';
      case VpnStage.connecting:
        return 'Connecting';
      case VpnStage.disconnected:
        return 'Disconnected';
      case VpnStage.disconnecting:
        return 'Disconnecting';
      case VpnStage.denied:
        return 'Denied';
      case VpnStage.authenticating:
        return 'Authenticating';
      case VpnStage.exiting:
        return 'Exiting';
      case VpnStage.noConnection:
        return 'No Connection';
      case VpnStage.preparing:
        return 'Preparing';
      case VpnStage.reconnect:
        return 'Reconnecting';
      case VpnStage.waitingConnection:
        return 'Waiting Connection';
      default:
        return 'Getting connection status';
    }
  }

  static String getConnectionDescription(VpnStage? state) {
    switch (state) {
      case VpnStage.connected:
        return 'Your Internet is private';
      case VpnStage.disconnected:
        return 'Your Internet is not private';
      default:
        return '';
    }
  }

  static Color getConnectionColor(VpnStage? state) {
    switch (state) {
      case VpnStage.connected:
        return Color.fromARGB(255, 26, 48, 85);
      default:
        return Colors.grey;
    }
  }
} 