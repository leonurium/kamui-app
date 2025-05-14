import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:kamui_app/core/utils/connection_state_utils.dart';

class ConnectionDescriptionWidget extends StatelessWidget {
  final VpnStage? currentStage;

  const ConnectionDescriptionWidget({
    Key? key,
    required this.currentStage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final description = ConnectionStateUtils.getConnectionDescription(currentStage);
    final statusColor = currentStage == VpnStage.connected ? Colors.green : Colors.red;

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(
            text: description.prefix,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          TextSpan(
            text: description.status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ],
      ),
    );
  }
} 