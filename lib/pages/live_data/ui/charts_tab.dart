import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/pages/live_data/ui/charts/realtime_line_chart.dart';
import 'package:smart_car/pages/live_data/ui/charts/driving_heat_map.dart';
import 'package:smart_car/pages/live_data/ui/charts/trip_comparison_widget.dart';

/// Zakładka z wykresami w czasie rzeczywistym
class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  // Historia punktów dla mapy ciepła
  final List<HeatMapPoint> _heatMapPoints = [];
  double? _lastSpeed;
  DateTime? _lastSpeedTime;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: GlobalBlocs.liveData,
      builder: (context, state) {
        final cubit = GlobalBlocs.liveData;

        // Pobierz komendy
        final speedCmd = _getCommand<SpeedCommand>(cubit, Pids.speed);
        final rpmCmd = _getCommand(cubit, Pids.rpm);
        final loadCmd = _getCommand(cubit, Pids.engineLoad);
        final throttleCmd = _getCommand(cubit, Pids.throttlePosition);

        // Aktualizuj mapę ciepła
        _updateHeatMap(speedCmd, rpmCmd, state);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sekcja: Wykresy w czasie rzeczywistym
                _buildSectionHeader('Wykresy na żywo', Icons.show_chart),
                const SizedBox(height: 8),

                // Wykres prędkości
                if (speedCmd != null)
                  RealtimeLineChart(
                    data: speedCmd.historyData,
                    title: 'Prędkość',
                    unit: 'km/h',
                    color: Colors.blue,
                    minY: 0,
                    maxY: 180,
                    height: 120,
                  ),
                const SizedBox(height: 8),

                // Wykres RPM
                if (rpmCmd != null)
                  RealtimeLineChart(
                    data: rpmCmd.historyData,
                    title: 'Obroty silnika',
                    unit: 'RPM',
                    color: Colors.orange,
                    minY: 0,
                    maxY: 7000,
                    height: 120,
                  ),
                const SizedBox(height: 8),

                // Wykres obciążenia silnika
                if (loadCmd != null)
                  RealtimeLineChart(
                    data: loadCmd.historyData,
                    title: 'Obciążenie silnika',
                    unit: '%',
                    color: Colors.purple,
                    minY: 0,
                    maxY: 100,
                    height: 120,
                  ),
                const SizedBox(height: 8),

                // Wykres przepustnicy
                if (throttleCmd != null)
                  RealtimeLineChart(
                    data: throttleCmd.historyData,
                    title: 'Pozycja przepustnicy',
                    unit: '%',
                    color: Colors.green,
                    minY: 0,
                    maxY: 100,
                    height: 120,
                  ),
                const SizedBox(height: 16),

                // Sekcja: Mapa ciepła stylu jazdy
                _buildSectionHeader('Styl jazdy', Icons.speed),
                const SizedBox(height: 8),
                DrivingHeatMap(
                  points: _heatMapPoints,
                  rpmMin: 600,
                  rpmMax: 6000,
                  accMin: -8,
                  accMax: 8,
                  height: 220,
                ),
                const SizedBox(height: 16),

                // Sekcja: Statystyki bieżącej podróży
                _buildSectionHeader('Bieżąca podróż', Icons.route),
                const SizedBox(height: 8),
                _buildCurrentTripStats(state),
                const SizedBox(height: 16),

                // Sekcja: Porównanie z poprzednimi podróżami
                _buildSectionHeader('Porównanie', Icons.compare_arrows),
                const SizedBox(height: 8),
                _buildTripComparison(state),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  T? _getCommand<T extends VisibleObdCommand>(
    LiveDataCubit cubit,
    String pidHex,
  ) {
    final full = '01$pidHex';
    for (final c in cubit.commands) {
      if (c is T && c.command == full) return c;
    }
    // Fallback dla typów generycznych
    for (final c in cubit.commands) {
      if (c is VisibleObdCommand && c.command == full) return c as T?;
    }
    return null;
  }

  void _updateHeatMap(
    SpeedCommand? speedCmd,
    VisibleObdCommand? rpmCmd,
    LiveDataState state,
  ) {
    if (speedCmd == null || rpmCmd == null) return;

    final currentSpeed = speedCmd.result.toDouble();
    final currentRpm = rpmCmd.result.toDouble();
    final now = DateTime.now();

    // Oblicz przyspieszenie
    double acceleration = 0;
    if (_lastSpeed != null && _lastSpeedTime != null) {
      final timeDiff = now.difference(_lastSpeedTime!).inMilliseconds / 1000;
      if (timeDiff > 0 && timeDiff < 5) {
        acceleration = (currentSpeed - _lastSpeed!) / timeDiff; // km/h/s
      }
    }

    _lastSpeed = currentSpeed;
    _lastSpeedTime = now;

    // Zużycie paliwa
    final fuelConsumption = state.tripRecord.instFuelConsumption > 0
        ? state.tripRecord.instFuelConsumption
        : 0.0;

    // Dodaj punkt jeśli dane są sensowne
    if (currentRpm > 0 && currentSpeed >= 0 && fuelConsumption >= 0) {
      _heatMapPoints.add(
        HeatMapPoint(
          rpm: currentRpm,
          acceleration: acceleration,
          fuelConsumption: fuelConsumption,
        ),
      );

      // Ogranicz liczbę punktów
      if (_heatMapPoints.length > 500) {
        _heatMapPoints.removeAt(0);
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTripStats(LiveDataState state) {
    final trip = state.tripRecord;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.route,
                  label: 'Dystans',
                  value: '${trip.distance.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
                _StatItem(
                  icon: Icons.timer,
                  label: 'Czas',
                  value: _formatDuration(
                    Duration(seconds: trip.totalTripSeconds),
                  ),
                  color: Colors.purple,
                ),
                _StatItem(
                  icon: Icons.speed,
                  label: 'Śr. prędkość',
                  value:
                      '${trip.averageSpeed.isFinite ? trip.averageSpeed.toStringAsFixed(0) : 0} km/h',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.local_gas_station,
                  label: 'Śr. spalanie',
                  value:
                      '${trip.avgFuelConsumption.isFinite && trip.avgFuelConsumption > 0 ? trip.avgFuelConsumption.toStringAsFixed(1) : '--'} l/100',
                  color: _getFuelColor(trip.avgFuelConsumption),
                ),
                _StatItem(
                  icon: Icons.water_drop,
                  label: 'Zużyte paliwo',
                  value: '${trip.totalFuelUsed.toStringAsFixed(2)} l',
                  color: Colors.orange,
                ),
                _StatItem(
                  icon: Icons.eco,
                  label: 'Oszczędzone',
                  value: '${trip.savedFuel.toStringAsFixed(2)} l',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripComparison(LiveDataState state) {
    final trip = state.tripRecord;

    // Symulowane poprzednie podróże (w przyszłości pobierz z Firestore)
    // TODO: Zastąpić rzeczywistymi danymi z historii
    final previousTrips = <TripSummaryData>[
      TripSummaryData(
        date: DateTime.now().subtract(const Duration(days: 1)),
        distance: 25.3,
        duration: const Duration(minutes: 45),
        avgFuelConsumption: 7.2,
        avgSpeed: 33.7,
      ),
      TripSummaryData(
        date: DateTime.now().subtract(const Duration(days: 2)),
        distance: 18.5,
        duration: const Duration(minutes: 32),
        avgFuelConsumption: 6.8,
        avgSpeed: 34.7,
      ),
      TripSummaryData(
        date: DateTime.now().subtract(const Duration(days: 3)),
        distance: 42.1,
        duration: const Duration(hours: 1, minutes: 15),
        avgFuelConsumption: 7.5,
        avgSpeed: 33.7,
      ),
    ];

    final currentTrip = TripSummaryData(
      date: DateTime.now(),
      distance: trip.distance,
      duration: Duration(seconds: trip.totalTripSeconds),
      avgFuelConsumption:
          trip.avgFuelConsumption.isFinite && trip.avgFuelConsumption > 0
          ? trip.avgFuelConsumption
          : 0,
      avgSpeed: trip.averageSpeed.isFinite ? trip.averageSpeed : 0,
    );

    return Column(
      children: [
        TripComparisonWidget(
          currentTrip: currentTrip,
          previousTrips: previousTrips,
          height: 160,
        ),
        const SizedBox(height: 8),
        FuelTrendChart(trips: [...previousTrips, currentTrip], height: 150),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Color _getFuelColor(double fuel) {
    if (!fuel.isFinite || fuel <= 0) return Colors.grey;
    if (fuel < 6) return Colors.green;
    if (fuel < 8) return Colors.lightGreen;
    if (fuel < 10) return Colors.yellow.shade700;
    if (fuel < 12) return Colors.orange;
    return Colors.red;
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
