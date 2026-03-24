import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Model pojedynczego punktu danych dla mapy ciepła
class HeatMapPoint {
  const HeatMapPoint({
    required this.rpm,
    required this.acceleration,
    required this.fuelConsumption,
  });

  final double rpm;
  final double acceleration; // m/s² lub km/h różnica
  final double fuelConsumption; // l/100km

  @override
  String toString() =>
      'HeatMapPoint(rpm: $rpm, acc: $acceleration, fuel: $fuelConsumption)';
}

/// Mapa ciepła wizualizująca styl jazdy
/// Oś X: RPM (np. 800 - 6000)
/// Oś Y: Przyspieszenie (np. -10 do +10 km/h/s)
/// Kolor: Zużycie paliwa (zielony=niskie, czerwony=wysokie)
class DrivingHeatMap extends StatelessWidget {
  const DrivingHeatMap({
    super.key,
    required this.points,
    this.rpmMin = 800,
    this.rpmMax = 6000,
    this.accMin = -5,
    this.accMax = 5,
    this.height = 250,
    this.showSweetSpot = true,
    this.sweetSpotRpmMin = 1500,
    this.sweetSpotRpmMax = 2500,
    this.sweetSpotAccMin = 0,
    this.sweetSpotAccMax = 2,
  });

  final List<HeatMapPoint> points;
  final double rpmMin;
  final double rpmMax;
  final double accMin;
  final double accMax;
  final double height;
  final bool showSweetSpot;
  final double sweetSpotRpmMin;
  final double sweetSpotRpmMax;
  final double sweetSpotAccMin;
  final double sweetSpotAccMax;

  @override
  Widget build(BuildContext context) {
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
                  'Mapa stylu jazdy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, height),
                    painter: _HeatMapPainter(
                      points: points,
                      rpmMin: rpmMin,
                      rpmMax: rpmMax,
                      accMin: accMin,
                      accMax: accMax,
                      showSweetSpot: showSweetSpot,
                      sweetSpotRpmMin: sweetSpotRpmMin,
                      sweetSpotRpmMax: sweetSpotRpmMax,
                      sweetSpotAccMin: sweetSpotAccMin,
                      sweetSpotAccMax: sweetSpotAccMax,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildAxisLabels(),
            const SizedBox(height: 8),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        const Text('l/100km', style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildAxisLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '↑ Przyspieszenie',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '↓ Hamowanie',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const Text('RPM →', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStats() {
    if (points.isEmpty) {
      return const Text('Brak danych', style: TextStyle(color: Colors.grey));
    }

    int sweetSpotCount = 0;
    int aggressiveCount = 0;
    double totalFuel = 0;

    for (final p in points) {
      totalFuel += p.fuelConsumption;
      if (p.rpm >= sweetSpotRpmMin &&
          p.rpm <= sweetSpotRpmMax &&
          p.acceleration >= sweetSpotAccMin &&
          p.acceleration <= sweetSpotAccMax) {
        sweetSpotCount++;
      }
      if (p.acceleration.abs() > 3 || p.rpm > 4000) {
        aggressiveCount++;
      }
    }

    final sweetSpotPercent = (sweetSpotCount / points.length * 100)
        .toStringAsFixed(0);
    final aggressivePercent = (aggressiveCount / points.length * 100)
        .toStringAsFixed(0);
    final avgFuel = (totalFuel / points.length).toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatBox(
          label: 'W strefie eko',
          value: '$sweetSpotPercent%',
          color: Colors.green,
          icon: Icons.eco,
        ),
        _StatBox(
          label: 'Agresywna jazda',
          value: '$aggressivePercent%',
          color: Colors.red,
          icon: Icons.speed,
        ),
        _StatBox(
          label: 'Śr. zużycie',
          value: '$avgFuel l/100',
          color: Colors.blue,
          icon: Icons.local_gas_station,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _HeatMapPainter extends CustomPainter {
  _HeatMapPainter({
    required this.points,
    required this.rpmMin,
    required this.rpmMax,
    required this.accMin,
    required this.accMax,
    required this.showSweetSpot,
    required this.sweetSpotRpmMin,
    required this.sweetSpotRpmMax,
    required this.sweetSpotAccMin,
    required this.sweetSpotAccMax,
  });

  final List<HeatMapPoint> points;
  final double rpmMin;
  final double rpmMax;
  final double accMin;
  final double accMax;
  final bool showSweetSpot;
  final double sweetSpotRpmMin;
  final double sweetSpotRpmMax;
  final double sweetSpotAccMin;
  final double sweetSpotAccMax;

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 30.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final chartRect = Rect.fromLTWH(
      padding,
      padding / 2,
      chartWidth,
      chartHeight,
    );

    // Tło
    canvas.drawRect(chartRect, Paint()..color = Colors.grey.withOpacity(0.1));

    // Siatka
    _drawGrid(canvas, chartRect);

    // Sweet spot zone
    if (showSweetSpot) {
      _drawSweetSpotZone(canvas, chartRect);
    }

    // Punkty danych
    _drawDataPoints(canvas, chartRect);

    // Osie
    _drawAxes(canvas, chartRect, size);
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Linie poziome
    for (int i = 0; i <= 4; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }

    // Linie pionowe
    for (int i = 0; i <= 5; i++) {
      final x = rect.left + rect.width * i / 5;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
  }

  void _drawSweetSpotZone(Canvas canvas, Rect rect) {
    final left =
        rect.left + (sweetSpotRpmMin - rpmMin) / (rpmMax - rpmMin) * rect.width;
    final right =
        rect.left + (sweetSpotRpmMax - rpmMin) / (rpmMax - rpmMin) * rect.width;
    final top =
        rect.bottom -
        (sweetSpotAccMax - accMin) / (accMax - accMin) * rect.height;
    final bottom =
        rect.bottom -
        (sweetSpotAccMin - accMin) / (accMax - accMin) * rect.height;

    final sweetSpotRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, top, right, bottom),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      sweetSpotRect,
      Paint()
        ..color = Colors.green.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      sweetSpotRect,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDataPoints(Canvas canvas, Rect rect) {
    if (points.isEmpty) return;

    // Znajdź zakres zużycia paliwa
    double minFuel = double.infinity;
    double maxFuel = double.negativeInfinity;
    for (final p in points) {
      if (p.fuelConsumption.isFinite) {
        minFuel = math.min(minFuel, p.fuelConsumption);
        maxFuel = math.max(maxFuel, p.fuelConsumption);
      }
    }

    if (minFuel == double.infinity) return;
    final fuelRange = maxFuel - minFuel;

    for (final point in points) {
      final x =
          rect.left + (point.rpm - rpmMin) / (rpmMax - rpmMin) * rect.width;
      final y =
          rect.bottom -
          (point.acceleration - accMin) / (accMax - accMin) * rect.height;

      if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
        continue;
      }

      // Kolor na podstawie zużycia paliwa
      final normalizedFuel = fuelRange > 0
          ? (point.fuelConsumption - minFuel) / fuelRange
          : 0.5;
      final color = _getFuelColor(normalizedFuel);

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.fill,
      );
    }
  }

  Color _getFuelColor(double normalized) {
    // Gradient od zielonego (niskie) przez żółty do czerwonego (wysokie)
    if (normalized < 0.33) {
      return Color.lerp(Colors.green, Colors.yellow, normalized * 3)!;
    } else if (normalized < 0.66) {
      return Color.lerp(Colors.yellow, Colors.orange, (normalized - 0.33) * 3)!;
    } else {
      return Color.lerp(Colors.orange, Colors.red, (normalized - 0.66) * 3)!;
    }
  }

  void _drawAxes(Canvas canvas, Rect rect, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Etykiety osi X (RPM)
    final rpmLabels = [rpmMin, (rpmMin + rpmMax) / 2, rpmMax];
    for (int i = 0; i < rpmLabels.length; i++) {
      final x = rect.left + rect.width * i / (rpmLabels.length - 1);
      textPainter.text = TextSpan(
        text: rpmLabels[i].toInt().toString(),
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, rect.bottom + 2),
      );
    }

    // Etykiety osi Y (Przyspieszenie)
    final accLabels = [accMin, 0.0, accMax];
    for (int i = 0; i < accLabels.length; i++) {
      final y = rect.bottom - rect.height * i / (accLabels.length - 1);
      textPainter.text = TextSpan(
        text: accLabels[i].toStringAsFixed(0),
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left - textPainter.width - 4, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeatMapPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
