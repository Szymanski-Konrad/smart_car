import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class LiveDataTile extends StatelessWidget {
  const LiveDataTile({super.key, required this.command});

  final VisibleObdCommand command;

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

  Widget _chart(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final fillColor = command.color.withValues(alpha: 0.18);
    return Sparkline(
      lineWidth: 0,
      useCubicSmoothing: true,
      fallbackHeight: Constants.tileHeight,
      data: command.lastHistoryData,
      lineColor: lineColor,
      fillColor: fillColor,
      fillMode: FillMode.below,
      max: command.max.toDouble(),
      min: command.min.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tileWidthFactor = screenWidth >= Constants.largeScreenWidth
        ? 0.30
        : 0.25;
    final tileHeight = Constants.tileHeight + 30.0;

    final normalized = _normalizedValue();
    final trend = _trendDirection();
    final isPercent = command.unit.trim().contains('%');

    return GestureDetector(
      onTap: () => showDescription(context),
      child: SizedBox(
        height: tileHeight,
        width: screenWidth * tileWidthFactor,
        child: Stack(
          children: [
            if (command.enableHistorical && command.historyData.isNotEmpty)
              _chart(context),
            _commandInfo(
              context,
              normalized: normalized,
              trend: trend,
              isPercent: isPercent,
            ),
          ],
        ),
      ),
    );
  }

  void showDescription(BuildContext context) {
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

  Widget _commandInfo(
    BuildContext context, {
    required double? normalized,
    required int trend,
    required bool isPercent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = command.color;
    final outline = colorScheme.outlineVariant;

    final trendIcon = switch (trend) {
      1 => Icons.trending_up,
      -1 => Icons.trending_down,
      _ => Icons.trending_flat,
    };

    final bar = normalized == null
        ? const SizedBox.shrink()
        : ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 10,
              color: accent,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          );

    final gauge = normalized == null
        ? const SizedBox.shrink()
        : SizedBox(
            height: 34,
            width: 34,
            child: CircularProgressIndicator(
              value: normalized,
              strokeWidth: 6,
              color: accent,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          );

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: command.enableHistorical
            ? BorderSide.none
            : BorderSide(color: outline),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(command.icon, color: accent, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    command.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(trendIcon, color: accent, size: 22),
              ],
            ),
            const Spacer(),
            Text(
              command.formattedResult,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            if (isPercent)
              Align(alignment: Alignment.center, child: gauge)
            else
              bar,
          ],
        ),
      ),
    );
  }
}
