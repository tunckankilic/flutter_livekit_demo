import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ConnectionQualityIndicator extends StatelessWidget {
  final ConnectionQuality quality;

  const ConnectionQualityIndicator({Key? key, required this.quality})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    int bars;

    switch (quality) {
      case ConnectionQuality.excellent:
        color = Colors.green;
        bars = 3;
        break;
      case ConnectionQuality.good:
        color = Colors.green;
        bars = 2;
        break;
      case ConnectionQuality.poor:
        color = Colors.orange;
        bars = 1;
        break;
      default:
        color = Colors.red;
        bars = 0;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            width: 4,
            height: 6 + (i * 2),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: i < bars ? color : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
