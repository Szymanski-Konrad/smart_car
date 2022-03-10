import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/services/overpass_api.dart';

class FuelStationPage extends StatefulWidget {
  const FuelStationPage({Key? key}) : super(key: key);

  @override
  State<FuelStationPage> createState() => _FuelStationPageState();
}

class _FuelStationPageState extends State<FuelStationPage> {
  MapController mapController = MapController();

  List<ResponseLocation> locations = [];

  @override
  void initState() {
    super.initState();
    mapController.mapEventStream.listen(onMapEventStream);
  }

  Future<void> onMapEventStream(MapEvent event) async {
    print(event.source);
    if (event.source == MapEventSource.dragEnd) {
      QueryLocation location = QueryLocation(
        longitude: event.center.longitude,
        latitude: event.center.latitude,
      );
      final results = await OverpassApi.fetchGasStationsAroundCenter(
        location,
        {'amenity': 'fuel'},
        5000,
      );
      setState(() {
        locations = results;
      });
      print(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stacje paliw'),
        centerTitle: true,
      ),
      body: FlutterMap(
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
            markers: locations.map(_buildMarker).toList(),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(ResponseLocation location) {
    print(location);
    return Marker(
      width: 40,
      height: 40,
      point: LatLng(location.latitude, location.longitude),
      builder: (ctx) => const Icon(
        Icons.local_gas_station,
        color: Colors.blue,
        size: 40,
      ),
    );
  }
}
