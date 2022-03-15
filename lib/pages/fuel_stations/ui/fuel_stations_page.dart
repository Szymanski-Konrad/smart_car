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
  QueryLocation? location;

  @override
  void initState() {
    super.initState();
    mapController.mapEventStream.listen(onMapEventStream);
  }

  Future<void> onMapEventStream(MapEvent event) async {
    if (event.source == MapEventSource.dragEnd) {
      location = QueryLocation(
        longitude: event.center.longitude,
        latitude: event.center.latitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stacje paliw'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(52.43, 20.7),
                zoom: 13.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              mapController: mapController,
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              child: Column(
                children: [
                  Text('PB95'),
                  Text('PB98'),
                  Text('ON'),
                  Text('LPG'),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final _location = location;
          if (_location == null) return;
          final results = await OverpassApi.fetchGasStationsAroundCenter(
            _location,
            {'amenity': 'fuel'},
            5000,
          );
          setState(() {
            locations = results;
          });
        },
      ),
    );
  }

  Marker _buildMarker(ResponseLocation location) {
    print(location);
    return Marker(
      width: 60,
      height: 100,
      point: LatLng(location.latitude, location.longitude),
      builder: (ctx) => Column(
        children: [
          Card(
            child: Text('4,79 zł'),
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
}
