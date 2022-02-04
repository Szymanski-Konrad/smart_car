import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/text_styles.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/utils/info_tile_data.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final OtherTileData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${data.formattedValue} ${data.unit}',
          style: TextStyles.valueTextStyle,
        ),
        Text(
          data.title,
          style: TextStyles.descriptionTextStyle,
        ),
      ],
    );
  }
}

class FuelInfoTile extends StatelessWidget {
  const FuelInfoTile({
    Key? key,
    required this.data,
    required this.status,
  }) : super(key: key);

  final FuelTileData data;
  final TripStatus status;

  Color get color {
    if (status == TripStatus.driving) return Colors.orange;
    if (status == TripStatus.idle) return Colors.red;
    if (status == TripStatus.savingFuel) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              '${data.formattedValue} ${data.unit}',
              style: TextStyles.valueTextStyle,
            ),
            if (status == data.tripStatus)
              Icon(
                Icons.arrow_upward,
                color: color,
              ),
          ],
        ),
        Text(
          data.title,
          style: TextStyles.descriptionTextStyle,
        ),
      ],
    );
  }
}

class TimeInfoTile extends StatelessWidget {
  const TimeInfoTile({
    Key? key,
    required this.data,
    required this.currentInterval,
  }) : super(key: key);

  final TimeTileData data;
  final int currentInterval;

  String get intervalValue =>
      Duration(seconds: currentInterval).toString().substring(0, 7);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${data.formattedValue} ${data.unit}',
          style: TextStyles.valueTextStyle,
        ),
        Text(
          data.title,
          style: TextStyles.descriptionTextStyle,
        ),
        if (data.isCurrent)
          Text(
            '+$intervalValue ${data.unit}',
            style: TextStyles.smallValueTextStyle,
          ),
      ],
    );
  }
}
