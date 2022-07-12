import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/pages/station_details/ui/station_details_page.dart';
import 'package:smart_car/utils/ui/fuel_price_card.dart';

class FuelStationsMap extends StatefulWidget {
  const FuelStationsMap({
    Key? key,
    required this.onLocationChanged,
    required this.gasStations,
    required this.fuelType,
  }) : super(key: key);

  final Function(QueryLocation) onLocationChanged;
  final List<GasStation> gasStations;
  final FuelStationType fuelType;

  @override
  State<FuelStationsMap> createState() => _FuelStationsMapState();
}

class _FuelStationsMapState extends State<FuelStationsMap> {
  MapController mapController = MapController();

  List<ResponseLocation> locations = [];

  @override
  void initState() {
    super.initState();
    mapController.mapEventStream.listen(onMapEventStream);
    mapController.onReady.then((value) {
      widget.onLocationChanged(QueryLocation.fromLatLng(mapController.center));
    });
  }

  Future<void> onMapEventStream(MapEvent event) async {
    if (event.source == MapEventSource.dragEnd) {
      widget.onLocationChanged(QueryLocation.fromLatLng(event.center));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(52.43, 20.7),
        zoom: 13.0,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      mapController: mapController,
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: widget.gasStations.map(_buildMarker).toList(),
        ),
      ],
    );
  }

  Marker _buildMarker(GasStation station) {
    return Marker(
      width: 50,
      height: 30,
      point: station.coordinates,
      builder: (ctx) => Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.local_gas_station,
            color: Colors.blue,
            size: 24,
          ),
          Positioned(
            left: -15,
            bottom: -20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  barrierColor: Colors.transparent,
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return _buildBottomSheet(context, station);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 30,
                  width: 50,
                  child: Card(
                    child: Center(
                      child: Text(
                        '${station.fuelPrice(widget.fuelType)?.toStringAsFixed(2) ?? '-.-'} zł',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, GasStation station) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: Colors.blueGrey,
      ),
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section 1: Name & location
          ListTile(
            minVerticalPadding: 0,
            onTap: () => Navigation.instance.push(
              SharedRoutes.stationDetails,
              arguments: StationDetailsPageArguments(station: station),
            ),
            title: Text(station.stationName),
            subtitle: Text(station.address),
          ),
          const Divider(color: Colors.white, thickness: 2.0),
          // Section 2: Fuel prices from backend
          Wrap(
            children: [
              if (station.fuelPrices.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Ta stacja nie ma jeszcze dodanych cen'),
                  ),
                ),
              ...station.fuelPrices.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FuelPriceCard(
                    fuelInfo: entry.value,
                    type: entry.key,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
