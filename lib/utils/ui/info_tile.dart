import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/text_styles.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/media_query_extensions.dart';

class OtherInfoTile extends StatelessWidget {
  const OtherInfoTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final OtherTileData data;

  @override
  Widget build(BuildContext context) {
    final widthFactor = MediaQuery.of(context).isLarge
        ? Constants.largeInfoTileWidthFactor
        : Constants.infoTileWidthFactor;
    final icon = data.iconData;
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: Constants.infoTileHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '${data.formattedValue} ${data.unit}',
            style: TextStyles.valueTextStyle,
          ),
          if (icon != null) Icon(icon),
          Text(
            data.title,
            style: TextStyles.descriptionTextStyle,
          ),
        ],
      ),
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
    final widthFactor = MediaQuery.of(context).isLarge
        ? Constants.largeInfoTileWidthFactor
        : Constants.infoTileWidthFactor;
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: Constants.infoTileHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
      ),
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
    final widthFactor = MediaQuery.of(context).isLarge
        ? Constants.largeInfoTileWidthFactor
        : Constants.infoTileWidthFactor;
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: Constants.infoTileHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      ),
    );
  }
}
