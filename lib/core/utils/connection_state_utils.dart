import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

class ConnectionDescription {
  final String prefix;
  final String status;

  const ConnectionDescription(this.prefix, this.status);
}

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

  static ConnectionDescription getConnectionDescription(VpnStage? state) {
    switch (state) {
      case VpnStage.connected:
        return const ConnectionDescription('Your Internet is ', 'private');
      case VpnStage.disconnected:
        return const ConnectionDescription('Your Internet is ', 'not private');
      default:
        return const ConnectionDescription('', '');
    }
  }

  static Color getConnectionColor(VpnStage? state) {
    switch (state) {
      case VpnStage.connected:
        return Colors.green;
      case VpnStage.disconnected:
        return Colors.red;
      case VpnStage.connecting:
      case VpnStage.disconnecting:
      case VpnStage.denied:
      case VpnStage.authenticating:
      case VpnStage.exiting:
      case VpnStage.noConnection:
      case VpnStage.preparing:
      case VpnStage.reconnect:
      case VpnStage.waitingConnection:
      default:
        return Colors.grey;
    }
  }
} 