import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_cubit.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_state.dart';
import 'package:smart_car/services/overpass_api.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class FuelStationsPage extends StatelessWidget {
  const FuelStationsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stacje paliw'),
        centerTitle: true,
      ),
      body: ScopedListenerBlocBuilder<FuelStationsCubit, FuelStationsState>(
      create: (_) => FuelStationsCubit(      ),
      listener: (context, state) {
      },
      listenWhen: (previous, current) {
        return false;
      },
      builder: (context, state, cubit) {
        return state.isConnnectingError
            ? Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text(Strings.cannotConnect),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(
                    state.isLocalMode
                        ? Strings.progress(state.localTripProgress)
                        : state.isConnecting
                            ? Strings.connecting
                            : Strings.connected,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () =>
                          Navigation.instance.push(SharedRoutes.settings),
                      icon: const Icon(Icons.settings),
                    ),
                    IconButton(
                      onPressed: () async {
                        final files = await TripFiles.showFilesInDirectory();
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: Text(
                                    Strings.filesInDirectory(files.length)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        TripFiles.sendTripsToMail(files),
                                    child: const Text(Strings.sendFiles),
                                  ),
                                ],
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...files.map((e) => ListTile(
                                            title: Text(e),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.file_copy_sharp),
                    ),
                    if (state.supportedPids.isNotEmpty)
                      IconButton(
                        onPressed: () => showSupportedCommandsDialog(
                            context, state.supportedPids, cubit, state),
                        icon: const Icon(Icons.list),
                      )
                  ],
                ),
                body: SafeArea(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(
                              icon: Icon(Icons.time_to_leave_outlined),
                              text: Strings.liveData,
                            ),
                            Tab(
                              icon: Icon(Icons.bar_chart),
                              text: Strings.tripStats,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Expanded(
                          child: TabBarView(
                            children: [
                              LiveStatsSection(state: state, cubit: cubit),
                              TripStatsSection(state: state, cubit: cubit),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
      },
    );
    );
  }
}

class FuelStationPage extends StatefulWidget {
  const FuelStationPage({Key? key}) : super(key: key);

  @override
  State<FuelStationPage> createState() => _FuelStationPageState();
}

class _FuelStationPageState extends State<FuelStationPage> {






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Positioned.fill(
            child: 
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              child: Column(
                children: [
                  ...FuelStationType.values
                      .map(_buildStationType)
                      .toList(),
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

  Widget _buildStationType(FuelStationType type) {
    return GestureDetector(
      onTap: () {},
      child: Text(type.description),
    );
  }

  
}
