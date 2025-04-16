import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

class ConnectionButtonWidget extends StatelessWidget {
  final VpnStage currentStage;
  final VoidCallback onTap;
  final String buttonText;
  final Color buttonColor;

  const ConnectionButtonWidget({
    Key? key,
    required this.currentStage,
    required this.onTap,
    required this.buttonText,
    required this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(90),
      child: AvatarGlow(
        glowColor: currentStage != VpnStage.connected
            ? Colors.transparent
            : buttonColor,
        endRadius: 100.0,
        duration: Duration(milliseconds: 2000),
        repeat: currentStage != VpnStage.connected ? false : true,
        showTwoGlows: true,
        repeatPauseDuration: Duration(milliseconds: 100),
        shape: BoxShape.circle,
        child: Material(
          elevation: 0,
          shape: CircleBorder(),
          color: buttonColor,
          child: SizedBox(
            height: 150,
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  buttonText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 