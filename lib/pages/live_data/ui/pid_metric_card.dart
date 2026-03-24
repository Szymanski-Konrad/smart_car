import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class PidMetricCard extends StatelessWidget {
  const PidMetricCard({
    super.key,
    required this.command,
    this.showSparkline = true,
    this.showGauge = true,
  });

  final VisibleObdCommand command;
  final bool showSparkline;
  final bool showGauge;

  double? _normalizedValue() {
    final min = command.min.toDouble();
    final max = command.max.toDouble();
    final value = command.result.toDouble();

    if (!value.isFinite || !min.isFinite || !max.isFinite) return null;
    final range = max - min;
    if (range <= 0) return null;
    return ((value - min) / range).clamp(0.0, 1.0);
  }

  int _trendDirection() {
    final data = command.lastHistoryData;
    if (data.length < 2) return 0;
    final diff = data[data.length - 1] - data[data.length - 2];
    if (diff.abs() < 0.001) return 0;
    return diff > 0 ? 1 : -1;
  }

  void _showDescription(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(command.name),
          content: Text(command.description),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = command.color;

    final normalized = _normalizedValue();
    final trend = _trendDirection();

    final trendIcon = switch (trend) {
      1 => Icons.trending_up,
      -1 => Icons.trending_down,
      _ => Icons.trending_flat,
    };

    final isPercent = command.unit.trim().contains('%');

    final gauge = (!showGauge || normalized == null)
        ? null
        : SizedBox(
            height: 44,
            width: 44,
            child: CircularProgressIndicator(
              value: normalized,
              strokeWidth: 7,
              color: accent,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          );

    final bar = (!showGauge || normalized == null)
        ? null
        : ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 10,
              color: accent,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          );

    final history = command.enableHistorical
        ? command.lastHistoryData
        : const <double>[];
    final canSpark = showSparkline && history.length >= 2;

    return InkWell(
      onTap: () => _showDescription(context),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (canSpark)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.9,
                  child: Sparkline(
                    data: history,
                    lineWidth: 2,
                    useCubicSmoothing: true,
                    fillMode: FillMode.none,
                    lineColor: accent.withValues(alpha: 0.65),
                    fallbackHeight: 80,
                    min: command.min.toDouble(),
                    max: command.max.toDouble(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(command.icon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          command.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(trendIcon, color: accent, size: 20),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    command.formattedResult,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (normalized != null && showGauge)
                    Align(
                      alignment: Alignment.center,
                      child: isPercent ? gauge : null,
                    ),
                  if (normalized != null && showGauge && !isPercent) bar!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
