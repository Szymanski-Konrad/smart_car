import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';

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
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
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
      height: 100,
      point: station.coordinates,
      builder: (ctx) => Column(
        children: [
          GestureDetector(
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
            child: SizedBox(
              height: 30,
              width: 50,
              child: Card(
                child: Center(
                    child: Text(
                        '${station.fuelPrice(widget.fuelType) ?? '-.-'} zł')),
              ),
            ),
          ),
          const Icon(
            Icons.local_gas_station,
            color: Colors.blue,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, GasStation station) {
    return Container(
      color: Colors.black,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nazwa: ${station.name}'),
          const SizedBox(height: 8.0),
          Text('Ceny paliw: ${station.fuelPrices.toString()}'),
          Text('Lokalizacja ${station.coordinates.toSexagesimal()}'),
          if (station.brand != null) Text('Sieć: ${station.brand}'),
          if (station.city != null) Text('Miasto: ${station.city}'),
          if (station.openingHours != null)
            Text('Godziny otwarcia: ${station.openingHours}'),
          if (station.stationOperator != null)
            Text('Operator: ${station.stationOperator}'),
          if (station.street != null) Text('Ulica: ${station.street}'),
          if (station.hasDiesel == true) Text('Diesel ✅'),
          if (station.hasElectricity == true) Text('Prąd ✅'),
          if (station.hasLpg == true) Text('LPG ✅'),
          if (station.hasPb95 == true) Text('Pb95 ✅'),
          if (station.hasPb98 == true) Text('Pb98 ✅'),
          if (station.hasShop == true) Text('Sklep ✅}'),
        ],
      ),
    );
  }
}
