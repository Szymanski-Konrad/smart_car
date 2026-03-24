import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Model danych podsumowania podróży
class TripSummaryData {
  const TripSummaryData({
    required this.date,
    required this.distance,
    required this.duration,
    required this.avgFuelConsumption,
    required this.avgSpeed,
    this.ecoScore,
  });

  final DateTime date;
  final double distance; // km
  final Duration duration;
  final double avgFuelConsumption; // l/100km
  final double avgSpeed; // km/h
  final double? ecoScore;

  String get formattedDate => '${date.day}.${date.month}';
  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

/// Widget porównania bieżącej podróży z poprzednimi
class TripComparisonWidget extends StatelessWidget {
  const TripComparisonWidget({
    super.key,
    required this.currentTrip,
    required this.previousTrips,
    this.height = 200,
  });

  final TripSummaryData currentTrip;
  final List<TripSummaryData> previousTrips;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Porównanie z poprzednimi podróżami',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(height: height, child: _buildChart(context)),
            const SizedBox(height: 12),
            _buildComparison(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (previousTrips.isEmpty) {
      return const Center(
        child: Text(
          'Brak poprzednich podróży do porównania',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final allTrips = [...previousTrips, currentTrip];
    final maxFuel =
        allTrips
            .map((t) => t.avgFuelConsumption)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxFuel,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final trip = allTrips[groupIndex];
              return BarTooltipItem(
                '${trip.formattedDate}\n${trip.avgFuelConsumption.toStringAsFixed(1)} l/100km\n${trip.distance.toStringAsFixed(1)} km',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < allTrips.length) {
                  final isCurrentTrip = idx == allTrips.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isCurrentTrip ? 'Teraz' : allTrips[idx].formattedDate,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrentTrip
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentTrip
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxFuel / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxFuel / 4,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        barGroups: List.generate(allTrips.length, (index) {
          final trip = allTrips[index];
          final isCurrentTrip = index == allTrips.length - 1;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: trip.avgFuelConsumption,
                color: isCurrentTrip
                    ? Theme.of(context).primaryColor
                    : _getFuelColor(trip.avgFuelConsumption),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _getFuelColor(double fuel) {
    if (fuel < 6) return Colors.green;
    if (fuel < 8) return Colors.lightGreen;
    if (fuel < 10) return Colors.yellow.shade700;
    if (fuel < 12) return Colors.orange;
    return Colors.red;
  }

  Widget _buildComparison(BuildContext context) {
    if (previousTrips.isEmpty) return const SizedBox();

    final avgPrevFuel =
        previousTrips.map((t) => t.avgFuelConsumption).reduce((a, b) => a + b) /
        previousTrips.length;
    final fuelDiff = currentTrip.avgFuelConsumption - avgPrevFuel;
    final fuelDiffPercent = (fuelDiff / avgPrevFuel * 100).abs();
    final isBetter = fuelDiff < 0;

    final avgPrevSpeed =
        previousTrips.map((t) => t.avgSpeed).reduce((a, b) => a + b) /
        previousTrips.length;
    final speedDiff = currentTrip.avgSpeed - avgPrevSpeed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isBetter ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ComparisonItem(
            icon: Icons.local_gas_station,
            label: 'Spalanie',
            value:
                '${isBetter ? "-" : "+"}${fuelDiffPercent.toStringAsFixed(1)}%',
            isPositive: isBetter,
          ),
          _ComparisonItem(
            icon: Icons.speed,
            label: 'Śr. prędkość',
            value:
                '${speedDiff >= 0 ? "+" : ""}${speedDiff.toStringAsFixed(0)} km/h',
            isPositive: speedDiff >= 0,
          ),
          _ComparisonItem(
            icon: Icons.route,
            label: 'Dystans',
            value: '${currentTrip.distance.toStringAsFixed(1)} km',
            isPositive: true,
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  const _ComparisonItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPositive,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: isPositive ? Colors.green : Colors.red),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

/// Widget trendu spalania w czasie (wykres liniowy)
class FuelTrendChart extends StatelessWidget {
  const FuelTrendChart({super.key, required this.trips, this.height = 180});

  final List<TripSummaryData> trips;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Card(
        elevation: 2,
        child: SizedBox(
          height: height,
          child: const Center(
            child: Text(
              'Brak danych o spalaniu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final maxFuel =
        trips.map((t) => t.avgFuelConsumption).reduce((a, b) => a > b ? a : b) *
        1.2;
    final minFuel =
        trips.map((t) => t.avgFuelConsumption).reduce((a, b) => a < b ? a : b) *
        0.8;

    final spots = trips.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.avgFuelConsumption);
    }).toList();

    // Oblicz trend
    final avgFuel =
        trips.map((t) => t.avgFuelConsumption).reduce((a, b) => a + b) /
        trips.length;
    final firstHalfAvg =
        trips
            .take(trips.length ~/ 2 + 1)
            .map((t) => t.avgFuelConsumption)
            .reduce((a, b) => a + b) /
        (trips.length ~/ 2 + 1);
    final secondHalfAvg =
        trips
            .skip(trips.length ~/ 2)
            .map((t) => t.avgFuelConsumption)
            .reduce((a, b) => a + b) /
        (trips.length - trips.length ~/ 2);
    final trend = secondHalfAvg - firstHalfAvg;
    final isTrendPositive = trend < 0; // Mniejsze spalanie = lepiej

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trend spalania',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isTrendPositive ? Colors.green : Colors.red)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_down
                            : Icons.trending_up,
                        size: 14,
                        color: isTrendPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Avg: ${avgFuel.toStringAsFixed(1)} l/100km',
                        style: TextStyle(
                          fontSize: 11,
                          color: isTrendPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  minY: minFuel,
                  maxY: maxFuel,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxFuel - minFuel) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: (maxFuel - minFuel) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: trips.length > 7
                            ? (trips.length / 5).ceil().toDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < trips.length) {
                            return Text(
                              trips[idx].formattedDate,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: Colors.blue,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _getFuelColor(spot.y),
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.2),
                            Colors.blue.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Linia średniej
                    LineChartBarData(
                      spots: [
                        FlSpot(0, avgFuel),
                        FlSpot((trips.length - 1).toDouble(), avgFuel),
                      ],
                      isCurved: false,
                      color: Colors.grey,
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFuelColor(double fuel) {
    if (fuel < 6) return Colors.green;
    if (fuel < 8) return Colors.lightGreen;
    if (fuel < 10) return Colors.yellow.shade700;
    if (fuel < 12) return Colors.orange;
    return Colors.red;
  }
}
