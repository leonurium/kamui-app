import 'package:flutter/material.dart';
import 'package:kamui_app/domain/entities/ping_result.dart';

class ServerItemWidget extends StatelessWidget {
  final bool isFaded;
  final String label;
  final IconData icon;
  final String flagURL;
  final PingResult? pingResult;
  final VoidCallback onTap;
  final bool isEnabled;

  const ServerItemWidget({
    Key? key,
    required this.isFaded,
    required this.label,
    required this.icon,
    required this.flagURL,
    this.pingResult,
    required this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            flagURL,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.flag, size: 20, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isFaded ? Colors.grey : null,
                            ),
                          ),
                          if (pingResult != null)
                            Text(
                              '${pingResult!.mbps.toStringAsFixed(1)} Mbps • ${pingResult!.latency}ms',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: pingResult!.isOnline ? Colors.green : Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  icon,
                  color: isFaded ? Colors.grey : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
