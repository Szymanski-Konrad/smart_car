import 'package:flutter/material.dart';
import 'package:smart_car/utils/info_tile_data.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final InfoTileData data;

  static const valueTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
  static const descriptionTextStyle = TextStyle(
    fontSize: 16.0,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${data.formattedValue} ${data.unit}',
          style: valueTextStyle,
        ),
        Text(
          data.title,
          style: descriptionTextStyle,
        ),
      ],
    );
  }
}
