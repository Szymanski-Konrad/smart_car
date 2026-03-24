import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';

class DirectionTile extends StatelessWidget {
  const DirectionTile({
    super.key,
    required this.direction,
    required this.title,
    this.scale = 1.0,
  });

  final double direction;
  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tileWidthFactor = screenWidth >= Constants.largeScreenWidth
        ? 0.30
        : 0.25;
    final tileHeight = Constants.tileHeight + 30.0;

    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: tileHeight,
      width: screenWidth * tileWidthFactor,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              RotationTransition(
                turns: AlwaysStoppedAnimation(direction / 360),
                child: Transform.scale(
                  scale: 1.4 * scale,
                  child: const Icon(Icons.navigation),
                ),
              ),
              Text(
                direction.toStringAsFixed(0),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
