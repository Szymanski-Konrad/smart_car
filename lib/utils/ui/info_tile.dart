import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/text_styles.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/media_query_extensions.dart';

double _tileWidth(BuildContext context) {
  final widthFactor = MediaQuery.of(context).isLarge
      ? Constants.largeInfoTileWidthFactor
      : Constants.infoTileWidthFactor;
  return MediaQuery.of(context).size.width * widthFactor;
}

class _TileShell extends StatelessWidget {
  const _TileShell({
    required this.width,
    required this.height,
    required this.accent,
    this.watermarkIcon,
    required this.child,
  });

  final double width;
  final double height;
  final Color accent;
  final IconData? watermarkIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgA = Color.lerp(accent, colorScheme.surfaceContainerHighest, 0.92)!;
    final bgB = colorScheme.surfaceContainerHighest;
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgA, bgB],
            ),
            border: Border(left: BorderSide(color: accent, width: 6)),
          ),
          child: Stack(
            children: [
              if (watermarkIcon != null)
                Positioned(
                  top: -12,
                  right: -12,
                  child: Icon(
                    watermarkIcon,
                    size: 88,
                    color: accent.withValues(alpha: 0.12),
                  ),
                ),
              Padding(padding: const EdgeInsets.all(12), child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherInfoTile extends StatelessWidget {
  const OtherInfoTile(
    this.data, {
    super.key,
    this.previousValue,
    this.updates = const {},
  });

  final OtherTileData data;
  final double? previousValue;
  final Map<TripDataType, int> updates;

  int? get seconds {
    final durations = <int>[];
    final types = data.tripDataType;
    if (types == null) return null;
    for (final type in types) {
      final value = DateTimeHelper.secondsDiff(updates[type]);
      if (value != null) {
        durations.add(value);
      }
    }
    durations.sort();
    return durations.isEmpty ? null : durations.first;
  }

  Color? get fontColor {
    final duration = seconds;
    if (duration == null) {
      return Colors.transparent;
    }
    final alpha = ((255 - duration * 50) / 255).clamp(0.0, 1.0);
    return Colors.green.withValues(alpha: alpha);
  }

  Color diffTextStyle(double diff) {
    if (diff == 0) return Colors.grey;
    if (diff < 0) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  double? _numericValue() {
    final v = data.value;
    if (v is double) return v.isFinite ? v : null;
    if (v is int) return v.toDouble();
    return null;
  }

  bool get _isScore =>
      data.unit.trim() == 'pts' && data.title.toLowerCase().contains('score');
  bool get _isSpeed => data.unit.trim() == 'km/h';
  bool get _isDistance => data.unit.trim() == 'km';
  bool get _isFuelRate =>
      data.unit.contains('l/100km') || data.unit.trim() == 'l/h';
  bool get _isMoney => data.unit.trim() == 'PLN';
  bool get _isRange =>
      data.title.toLowerCase().contains('range') ||
      data.title.toLowerCase().contains('zasi');

  Color _accentFor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final v = _numericValue();

    if (_isScore && v != null) {
      if (v < 40) return colorScheme.error;
      if (v < 70) return colorScheme.tertiary;
      return colorScheme.primary;
    }

    if (_isSpeed && v != null) {
      if (v > 130) return colorScheme.error;
      if (v > 110) return colorScheme.tertiary;
      return colorScheme.primary;
    }

    if (_isFuelRate && v != null) {
      // Lower is better.
      if (v > 14) return colorScheme.error;
      if (v > 9) return colorScheme.tertiary;
      return colorScheme.primary;
    }

    if (_isMoney) return colorScheme.secondary;
    if (_isRange) return colorScheme.primary;
    if (_isDistance) return colorScheme.secondary;

    return data.fontColor ?? colorScheme.primary;
  }

  Widget _valueVisual(BuildContext context, Color accent) {
    final colorScheme = Theme.of(context).colorScheme;
    final v = _numericValue();
    if (v == null) return const SizedBox.shrink();

    double clamp01(double x) => x.clamp(0.0, 1.0);

    if (_isScore) {
      final progress = clamp01(v / 100.0);
      return SizedBox(
        height: 34,
        width: 34,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 6,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    if (_isSpeed) {
      final progress = clamp01(v / 160.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    if (_isFuelRate) {
      final max = data.unit.contains('l/100km') ? 20.0 : 12.0;
      final progress = clamp01(v / max);
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    if (_isRange) {
      final progress = clamp01(v / 800.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    if (_isDistance) {
      // Progress to the next 10km milestone (gives motion while driving).
      final progress = clamp01((v % 10) / 10.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    if (_isMoney) {
      // Simple visual weight for costs.
      final progress = clamp01(v / 500.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: accent,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget diffText() {
    final prevValue = previousValue;
    if (prevValue == null) return const SizedBox();
    final diff = (data.value as double) - prevValue;
    final text = '${diff < 0 ? '-' : '+'} ${diff.abs().toStringAsFixed(0)}';
    return Text(
      text,
      style: TextStyles.valueTextStyle.copyWith(color: diffTextStyle(diff)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = _tileWidth(context);
    final height = Constants.infoTileHeight + 18;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentFor(context);
    final icon = data.iconData;
    final fallbackIcon = _isScore
        ? Icons.emoji_events
        : _isSpeed
        ? Icons.speed
        : _isFuelRate
        ? Icons.local_gas_station
        : _isRange
        ? Icons.ev_station
        : _isDistance
        ? Icons.route
        : _isMoney
        ? Icons.payments
        : null;

    final leadingIcon = icon ?? fallbackIcon;

    final visual = _valueVisual(context, accent);

    return Stack(
      children: [
        _TileShell(
          width: width,
          height: height,
          accent: accent,
          watermarkIcon: leadingIcon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: accent, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isScore) ...[const SizedBox(width: 8), visual],
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${data.formattedValue} ${data.unit}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: data.fontColor ?? colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  diffText(),
                ],
              ),
              if (!_isScore && visual is! SizedBox) ...[
                const SizedBox(height: 10),
                visual,
              ],
            ],
          ),
        ),
        if (seconds != null)
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(backgroundColor: fontColor, radius: 6),
          ),
      ],
    );
  }
}

class FuelInfoTile extends StatelessWidget {
  const FuelInfoTile({
    super.key,
    required this.data,
    required this.status,
    this.totalFuel,
  });

  final FuelTileData data;
  final TripStatus status;
  final double? totalFuel;

  Color get color {
    if (status == TripStatus.driving) return Colors.orange;
    if (status == TripStatus.idle) return Colors.red;
    if (status == TripStatus.savingFuel) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final width = _tileWidth(context);
    final height = Constants.infoTileHeight + 18;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color;
    final icon = switch (data.tripStatus) {
      TripStatus.driving => Icons.local_gas_station,
      TripStatus.idle => Icons.traffic,
      TripStatus.savingFuel => Icons.savings,
    };

    final value = data.value;
    final valueDouble = value is num ? value.toDouble() : null;
    final total = totalFuel;
    final percent =
        (valueDouble != null &&
            total != null &&
            total.isFinite &&
            total > 0 &&
            valueDouble.isFinite &&
            valueDouble >= 0)
        ? (valueDouble / total).clamp(0.0, 1.0)
        : null;

    return _TileShell(
      width: width,
      height: height,
      accent: accent,
      watermarkIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data.formattedValue} ${data.unit}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              if (status == data.tripStatus) ...[
                const SizedBox(width: 6),
                Icon(Icons.circle, size: 10, color: accent),
              ],
            ],
          ),
          if (percent != null) ...[
            const SizedBox(height: 8),
            Text(
              '${(percent * 100).toStringAsFixed(0)}% całkowitego paliwa',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                color: accent,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TimeInfoTile extends StatelessWidget {
  const TimeInfoTile({
    super.key,
    required this.data,
    required this.currentInterval,
    this.totalTripSeconds,
  });

  final TimeTileData data;
  final int currentInterval;
  final int? totalTripSeconds;

  String get intervalValue =>
      Duration(seconds: currentInterval).toString().substring(0, 7);

  @override
  Widget build(BuildContext context) {
    final width = _tileWidth(context);
    final height = Constants.infoTileHeight + 18;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = data.fontColor ?? colorScheme.secondary;
    final icon = data.isCurrent ? Icons.timer : Icons.schedule;
    final seconds = (data.value is Duration)
        ? (data.value as Duration).inSeconds
        : null;
    final total = totalTripSeconds;
    final percent =
        (seconds != null && total != null && total > 0 && seconds >= 0)
        ? (seconds / total).clamp(0.0, 1.0)
        : null;

    return _TileShell(
      width: width,
      height: height,
      accent: accent,
      watermarkIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${data.formattedValue} ${data.unit}',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          if (percent != null) ...[
            const SizedBox(height: 8),
            Text(
              '${(percent * 100).toStringAsFixed(0)}% całkowitego czasu',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                color: accent,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
          if (data.isCurrent) ...[
            const SizedBox(height: 6),
            Text(
              '+$intervalValue ${data.unit}',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
