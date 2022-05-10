import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';

class DirectionTile extends StatelessWidget {
  const DirectionTile({
    Key? key,
    required this.direction,
    required this.title,
    this.scale = 1.0,
  }) : super(key: key);

  final double direction;
  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.tileHeight,
      width: MediaQuery.of(context).size.width * 0.31,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RotationTransition(
            turns: AlwaysStoppedAnimation(direction / 360),
            child: const Icon(Icons.arrow_upward),
          ),
          Text(title),
          Text(direction.toStringAsFixed(2)),
        ],
      ),
    );
  }
}
