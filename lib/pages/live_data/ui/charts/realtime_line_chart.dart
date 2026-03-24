import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget wykresu liniowego w czasie rzeczywistym
class RealtimeLineChart extends StatelessWidget {
  const RealtimeLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.unit,
    required this.color,
    this.minY,
    this.maxY,
    this.height = 150,
    this.showGrid = true,
    this.showDots = false,
  });

  final List<double> data;
  final String title;
  final String unit;
  final Color color;
  final double? minY;
  final double? maxY;
  final double height;
  final bool showGrid;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('Brak danych', style: TextStyle(color: Colors.grey[400])),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final value = data[i];
      if (value.isFinite) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Brak prawidłowych danych')),
      );
    }

    final values = spots.map((s) => s.y).toList();
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final currentValue = values.last;

    final effectiveMinY =
        minY ?? (dataMin - (dataMax - dataMin) * 0.1).clamp(0, double.infinity);
    final effectiveMaxY = maxY ?? (dataMax + (dataMax - dataMin) * 0.1);

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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentValue.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  minY: effectiveMinY,
                  maxY: effectiveMaxY,
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  gridData: FlGridData(
                    show: showGrid,
                    drawVerticalLine: false,
                    horizontalInterval: (effectiveMaxY - effectiveMinY) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (effectiveMaxY - effectiveMinY) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: data.length > 10
                            ? (data.length / 5).ceil().toDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final secondsAgo = (data.length - 1 - value.toInt());
                          if (secondsAgo == 0) {
                            return const Text(
                              'teraz',
                              style: TextStyle(fontSize: 9),
                            );
                          }
                          return Text(
                            '-${secondsAgo}s',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 9,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: color,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: showDots,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: color,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} $unit',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatLabel('Min', dataMin.toStringAsFixed(1), unit),
                _StatLabel(
                  'Avg',
                  (values.reduce((a, b) => a + b) / values.length)
                      .toStringAsFixed(1),
                  unit,
                ),
                _StatLabel('Max', dataMax.toStringAsFixed(1), unit),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel(this.label, this.value, this.unit);
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        Text(
          '$value $unit',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        ),
      ],
    );
  }
}
