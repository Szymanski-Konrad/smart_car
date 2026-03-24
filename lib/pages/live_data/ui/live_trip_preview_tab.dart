import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/info_tile_data.dart';

class LiveTripPreviewTab extends StatelessWidget {
  const LiveTripPreviewTab({super.key});

  VisibleObdCommand? _pid(LiveDataCubit cubit, String pidHex) {
    final full = '01$pidHex';
    for (final c in cubit.commands) {
      if (c is VisibleObdCommand && c.command == full) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: GlobalBlocs.liveData,
      builder: (context, state) {
        final cubit = GlobalBlocs.liveData;
        final trip = state.tripRecord;

        final speedCmd = _pid(cubit, Pids.speed);
        final rpmCmd = _pid(cubit, Pids.rpm);
        final fuelLevelCmd = _pid(cubit, Pids.fuelLevel);
        final loadCmd = _pid(cubit, Pids.engineLoad);
        final coolantCmd = _pid(cubit, Pids.engineCoolant);
        final intakeTempCmd = _pid(cubit, Pids.intakeAirTemp);
        final oilTempCmd = _pid(cubit, Pids.oilTemp);
        final ambientTempCmd = _pid(cubit, Pids.ambientAirTemperature);
        final throttleCmd = _pid(cubit, Pids.throttlePosition);
        final voltageCmd = _pid(cubit, Pids.controlModuleVoltage);
        final mafCmd = _pid(cubit, Pids.maf);
        final mapCmd = _pid(cubit, Pids.intakeManifoldAbsolutePressure);
        final timingCmd = _pid(cubit, Pids.timingAdvance);

        final m = _LiveMetrics(
          state: state,
          trip: trip,
          speedCmd: speedCmd,
          rpmCmd: rpmCmd,
          fuelLevelCmd: fuelLevelCmd,
          loadCmd: loadCmd,
          coolantCmd: coolantCmd,
          intakeTempCmd: intakeTempCmd,
          oilTempCmd: oilTempCmd,
          ambientTempCmd: ambientTempCmd,
          throttleCmd: throttleCmd,
          voltageCmd: voltageCmd,
          mafCmd: mafCmd,
          mapCmd: mapCmd,
          timingCmd: timingCmd,
        );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= constraints.maxHeight;
                final cols = isWide ? 3 : 2;
                final maxRowsPerPage = isWide ? 2 : 3;
                const gap = 12.0;

                final specs = _buildTileSpecs(m);
                final pages = _packIntoPages(
                  specs,
                  cols: cols,
                  maxRows: maxRowsPerPage,
                );

                return PageView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _TilesPage(rows: pages[index], cols: cols, gap: gap);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LiveMetrics {
  const _LiveMetrics({
    required this.state,
    required this.trip,
    required this.speedCmd,
    required this.rpmCmd,
    required this.fuelLevelCmd,
    required this.loadCmd,
    required this.coolantCmd,
    required this.intakeTempCmd,
    required this.oilTempCmd,
    required this.ambientTempCmd,
    required this.throttleCmd,
    required this.voltageCmd,
    required this.mafCmd,
    required this.mapCmd,
    required this.timingCmd,
  });

  final LiveDataState state;
  final TripRecord trip;

  final VisibleObdCommand? speedCmd;
  final VisibleObdCommand? rpmCmd;
  final VisibleObdCommand? fuelLevelCmd;
  final VisibleObdCommand? loadCmd;
  final VisibleObdCommand? coolantCmd;

  final VisibleObdCommand? intakeTempCmd;
  final VisibleObdCommand? oilTempCmd;
  final VisibleObdCommand? ambientTempCmd;
  final VisibleObdCommand? throttleCmd;
  final VisibleObdCommand? voltageCmd;
  final VisibleObdCommand? mafCmd;
  final VisibleObdCommand? mapCmd;
  final VisibleObdCommand? timingCmd;
}

class _TileSpec {
  const _TileSpec({
    required this.spanPortrait,
    required this.spanLandscape,
    required this.builder,
  });

  final int spanPortrait;
  final int spanLandscape;
  final Widget Function(BuildContext context) builder;

  int spanFor({required int cols, required bool isWide}) {
    final desired = isWide ? spanLandscape : spanPortrait;
    if (desired <= 1) return 1;
    return desired.clamp(1, cols);
  }
}

class _PackedTile {
  const _PackedTile({required this.span, required this.child});
  final int span;
  final Widget child;
}

List<_TileSpec> _buildTileSpecs(_LiveMetrics m) {
  double? numFrom(VisibleObdCommand? c) {
    if (c == null) return null;
    final v = c.result.toDouble();
    return v.isFinite ? v : null;
  }

  final speed =
      numFrom(m.speedCmd) ??
      (m.trip.currentSpeed >= 0 ? m.trip.currentSpeed.toDouble() : null);

  final avgSpeed = m.trip.averageSpeed.isFinite && m.trip.averageSpeed >= 0
      ? m.trip.averageSpeed
      : null;

  final rpm = numFrom(m.rpmCmd);
  final fuelPct =
      numFrom(m.fuelLevelCmd) ??
      ((m.trip.currentFuelLvl.isFinite && m.trip.currentFuelLvl >= 0)
          ? m.trip.currentFuelLvl
          : null);
  final loadPct = numFrom(m.loadCmd);
  final coolant = numFrom(m.coolantCmd);
  final intakeTemp = numFrom(m.intakeTempCmd);
  final oilTemp = numFrom(m.oilTempCmd);
  final ambientTemp = numFrom(m.ambientTempCmd);
  final throttlePct = numFrom(m.throttleCmd);
  final voltage = numFrom(m.voltageCmd);
  final maf = numFrom(m.mafCmd);
  final map = numFrom(m.mapCmd);
  final timing = numFrom(m.timingCmd);

  final tiles = <_TileSpec>[
    _TileSpec(
      spanPortrait: 2,
      spanLandscape: 3,
      builder: (context) => _GaugeTile(
        title: 'Prędkość',
        icon: Icons.speed,
        value: speed,
        unit: 'km/h',
        max: 180,
        carStyle: true,
        overlayLabel: avgSpeed == null
            ? null
            : 'Śr. ${avgSpeed.toStringAsFixed(0)} km/h',
      ),
    ),
    _TileSpec(
      spanPortrait: 1,
      spanLandscape: 1,
      builder: (context) => _GaugeTile(
        title: 'RPM',
        icon: Icons.tune,
        value: rpm,
        unit: '',
        max: 7000,
        valueDigits: 0,
        carStyle: true,
      ),
    ),
    _TileSpec(
      spanPortrait: 1,
      spanLandscape: 1,
      builder: (context) => _PercentFillTile(
        title: 'Poziom paliwa',
        icon: Icons.local_gas_station,
        percent: fuelPct,
        suffix: '%',
      ),
    ),
    _TileSpec(
      spanPortrait: 1,
      spanLandscape: 1,
      builder: (context) => _PercentFillTile(
        title: 'Obciążenie',
        icon: Icons.auto_graph,
        percent: loadPct,
        suffix: '%',
      ),
    ),
    _TileSpec(
      spanPortrait: 2,
      spanLandscape: 2,
      builder: (context) => _FuelConsumptionSummaryTile(
        instant: m.trip.instFuelDetails,
        average: m.trip.avgFuelDetails,
        used: m.trip.usedFuelDetails,
        idleUsed: m.trip.idleUsedFuelDetails,
        saved: m.trip.savedFuelDetails,
      ),
    ),
    _TileSpec(
      spanPortrait: 1,
      spanLandscape: 1,
      builder: (context) =>
          _DualScoreTile(eco: m.state.ecoScore, smooth: m.state.smoothScore),
    ),
    _TileSpec(
      spanPortrait: 1,
      spanLandscape: 1,
      builder: (context) => _TripMetricCard.fromInfoTileData(
        m.trip.distanceDetails,
        icon: Icons.route,
      ),
    ),
    _TileSpec(
      spanPortrait: 2,
      spanLandscape: 1,
      builder: (context) => _TimeSummaryTile(
        totalSeconds: m.trip.totalTripSeconds,
        idleSeconds: m.trip.idleTripSeconds,
        continuousDriveSeconds: m.trip.currentDriveInterval,
        overRpmSeconds: m.trip.overRPMDriveTime,
        underRpmSeconds: m.trip.underRPMDriveTime,
      ),
    ),
    _TileSpec(
      spanPortrait: 2,
      spanLandscape: 1,
      builder: (context) => _TemperatureTile(
        title: 'Temp. cieczy',
        icon: Icons.thermostat,
        temperature: coolant,
        unit: m.coolantCmd?.unit ?? '°C',
        min: 40,
        max: 120,
        warnAt: 100,
        dangerAt: 110,
        coldAt: 70,
      ),
    ),
    if (m.intakeTempCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TemperatureTile(
          title: 'Temp. dolotu',
          icon: Icons.air,
          temperature: intakeTemp,
          unit: m.intakeTempCmd!.unit,
          min: -10,
          max: 80,
          warnAt: 50,
          dangerAt: 70,
          coldAt: 5,
        ),
      ),
    if (m.oilTempCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TemperatureTile(
          title: 'Temp. oleju',
          icon: Icons.oil_barrel,
          temperature: oilTemp,
          unit: m.oilTempCmd!.unit,
          min: 40,
          max: 150,
          warnAt: 120,
          dangerAt: 135,
          coldAt: 70,
        ),
      ),
    if (m.ambientTempCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TemperatureTile(
          title: 'Temp. zewn.',
          icon: Icons.thermostat_auto,
          temperature: ambientTemp,
          unit: m.ambientTempCmd!.unit,
          min: -20,
          max: 50,
          warnAt: 30,
          dangerAt: 40,
          coldAt: 0,
        ),
      ),
    if (m.throttleCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _PercentFillTile(
          title: 'Przepustnica',
          icon: Icons.sports_motorsports,
          percent: throttlePct,
          suffix: '%',
        ),
      ),
    if (m.voltageCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TripMetricCard(
          title: 'Napięcie',
          valueText: voltage == null ? '--' : voltage.toStringAsFixed(1),
          unit: m.voltageCmd!.unit,
          icon: Icons.bolt,
        ),
      ),
    if (m.mafCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TripMetricCard(
          title: 'MAF',
          valueText: maf == null ? '--' : maf.toStringAsFixed(1),
          unit: m.mafCmd!.unit,
          icon: Icons.air,
        ),
      ),
    if (m.mapCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TripMetricCard(
          title: 'MAP',
          valueText: map == null ? '--' : map.toStringAsFixed(0),
          unit: m.mapCmd!.unit,
          icon: Icons.compress,
        ),
      ),
    if (m.timingCmd != null)
      _TileSpec(
        spanPortrait: 1,
        spanLandscape: 1,
        builder: (context) => _TripMetricCard(
          title: 'Zapłon',
          valueText: timing == null ? '--' : timing.toStringAsFixed(0),
          unit: m.timingCmd!.unit,
          icon: Icons.bolt,
        ),
      ),
    // Kafelek ze statusem systemu paliwowego
    _TileSpec(
      spanPortrait: 2,
      spanLandscape: 1,
      builder: (context) =>
          _FuelSystemStatusTile(status: m.state.fuelSystemStatus),
    ),
  ];

  return tiles;
}

List<List<List<_PackedTile>>> _packIntoPages(
  List<_TileSpec> specs, {
  required int cols,
  required int maxRows,
}) {
  final pages = <List<List<_PackedTile>>>[];
  var currentPage = <List<_PackedTile>>[];
  var currentRow = <_PackedTile>[];
  var usedInRow = 0;

  void finalizeRow() {
    if (currentRow.isEmpty) return;
    currentPage.add(currentRow);
    currentRow = <_PackedTile>[];
    usedInRow = 0;
    if (currentPage.length >= maxRows) {
      pages.add(currentPage);
      currentPage = <List<_PackedTile>>[];
    }
  }

  // We pack using a conservative rule: portrait uses cols=2, landscape cols=3.
  // The span itself is stored later per layout; here we pack by max span for the page.
  for (final spec in specs) {
    // Pack assuming the tile wants to be wide if possible.
    final span = spec.spanLandscape.clamp(1, cols);
    final spanInRow = span;

    if (spanInRow > cols) {
      finalizeRow();
      currentRow.add(
        _PackedTile(
          span: cols,
          child: Builder(builder: spec.builder),
        ),
      );
      finalizeRow();
      continue;
    }

    if (usedInRow + spanInRow > cols) {
      finalizeRow();
    }

    currentRow.add(
      _PackedTile(
        span: spanInRow,
        child: Builder(builder: spec.builder),
      ),
    );
    usedInRow += spanInRow;
    if (usedInRow >= cols) {
      finalizeRow();
    }
  }

  finalizeRow();
  if (currentPage.isNotEmpty) pages.add(currentPage);

  if (pages.isEmpty) {
    pages.add([
      [
        const _PackedTile(
          span: 1,
          child: _TripMetricCard(
            title: '—',
            valueText: '--',
            unit: '',
            icon: Icons.dashboard,
          ),
        ),
      ],
    ]);
  }

  return pages;
}

class _TilesPage extends StatelessWidget {
  const _TilesPage({required this.rows, required this.cols, required this.gap});

  final List<List<_PackedTile>> rows;
  final int cols;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int r = 0; r < rows.length; r++) ...[
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < rows[r].length; i++) ...[
                  Expanded(flex: rows[r][i].span, child: rows[r][i].child),
                  if (i != rows[r].length - 1) SizedBox(width: gap),
                ],
              ],
            ),
          ),
          if (r != rows.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class _GaugeTile extends StatelessWidget {
  const _GaugeTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    required this.max,
    this.valueDigits = 0,
    this.overlayLabel,
    this.carStyle = false,
  });

  final String title;
  final IconData icon;
  final double? value;
  final String unit;
  final double max;
  final int valueDigits;
  final String? overlayLabel;
  final bool carStyle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final v = value;
    final normalized = (v != null && v.isFinite && max > 0)
        ? (v / max).clamp(0.0, 1.0)
        : null;

    final valueText = v == null
        ? '--'
        : (unit.isEmpty
              ? v.toStringAsFixed(valueDigits)
              : '${v.toStringAsFixed(valueDigits)} $unit');

    final scaleLabels = <_CarGaugeLabel>[];
    if (carStyle && max > 0) {
      // Provide a speedometer/tachometer-like numbered scale.
      if (unit == 'km/h') {
        for (int s = 0; s <= max.round(); s += 20) {
          scaleLabels.add(_CarGaugeLabel(s / max, '$s'));
        }
      } else if (title == 'RPM') {
        // Show thousands (0..7) like a car tachometer.
        for (int s = 0; s <= max.round(); s += 1000) {
          scaleLabels.add(_CarGaugeLabel(s / max, '${(s / 1000).round()}'));
        }
      }
    }

    return _CardShell(
      padding: carStyle ? const EdgeInsets.all(10) : const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (overlayLabel != null)
                Text(
                  overlayLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: carStyle ? 6 : 10),
          Expanded(
            child: carStyle
                ? _AnimatedCarGauge(
                    value: normalized ?? 0,
                    showNeedle: normalized != null,
                    background: cs.surfaceContainerHighest,
                    needle: cs.onSurface,
                    okColor: cs.primary,
                    warnColor: cs.tertiary,
                    dangerColor: cs.error,
                    labels: scaleLabels,
                    dialFill: cs.surface,
                    dialBorder: cs.onSurfaceVariant,
                  )
                : _SemiGauge(value: normalized, color: cs.primary),
          ),
          Text(
            valueText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: carStyle ? 6 : 10),
          if (overlayLabel != null)
            Text(
              overlayLabel!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _SemiGauge extends StatelessWidget {
  const _SemiGauge({required this.value, required this.color});
  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _SemiGaugePainter(
        value: value,
        color: color,
        background: cs.surfaceContainerHighest,
        needle: cs.onSurface,
      ),
    );
  }
}

class _AnimatedCarGauge extends ImplicitlyAnimatedWidget {
  const _AnimatedCarGauge({
    required this.value,
    required this.showNeedle,
    required this.background,
    required this.needle,
    required this.okColor,
    required this.warnColor,
    required this.dangerColor,
    required this.labels,
    required this.dialFill,
    required this.dialBorder,
  }) : super(
         duration: const Duration(milliseconds: 420),
         curve: Curves.easeOutCubic,
       );

  final double value;
  final bool showNeedle;
  final Color background;
  final Color needle;
  final Color okColor;
  final Color warnColor;
  final Color dangerColor;
  final List<_CarGaugeLabel> labels;

  final Color dialFill;
  final Color dialBorder;

  @override
  AnimatedWidgetBaseState<_AnimatedCarGauge> createState() =>
      _AnimatedCarGaugeState();
}

class _AnimatedCarGaugeState
    extends AnimatedWidgetBaseState<_AnimatedCarGauge> {
  Tween<double>? _value;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _value =
        visitor(
              _value,
              widget.value.clamp(0.0, 1.0),
              (dynamic v) => Tween<double>(begin: v as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final v = (_value?.evaluate(animation) ?? widget.value).clamp(0.0, 1.0);
    return CustomPaint(
      painter: _CarGaugePainter(
        value: v,
        showNeedle: widget.showNeedle,
        background: widget.background,
        needle: widget.needle,
        okColor: widget.okColor,
        warnColor: widget.warnColor,
        dangerColor: widget.dangerColor,
        labels: widget.labels,
        dialFill: widget.dialFill,
        dialBorder: widget.dialBorder,
      ),
    );
  }
}

class _CarGaugeLabel {
  const _CarGaugeLabel(this.t, this.text);
  final double t;
  final String text;
}

class _CarGaugePainter extends CustomPainter {
  const _CarGaugePainter({
    required this.value,
    required this.showNeedle,
    required this.background,
    required this.needle,
    required this.okColor,
    required this.warnColor,
    required this.dangerColor,
    required this.labels,
    required this.dialFill,
    required this.dialBorder,
  });

  final double value;
  final bool showNeedle;
  final Color background;
  final Color needle;
  final Color okColor;
  final Color warnColor;
  final Color dangerColor;

  final List<_CarGaugeLabel> labels;
  final Color dialFill;
  final Color dialBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = value.clamp(0.0, 1.0);
    final stroke = (size.height / 8.0).clamp(10.0, 18.0);
    // For a 240° sweep we need a slightly different center/radius than a simple
    // 180° semi-gauge to avoid clipping.
    final center = Offset(size.width / 2, size.height * 0.965);
    final radius =
        math.min(size.width / 2, size.height).clamp(0.0, double.infinity) -
        stroke * 0.85;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 240° arc like most car speedometers/tachometers.
    // Centered so the dial doesn't look rotated to the right.
    // Start at ~150° (bottom-left) and sweep clockwise to ~30° (bottom-right).
    const startAngle = 5 * math.pi / 6;
    const sweepAngle = 4 * math.pi / 3;

    // Dial / bezel background to feel more like a real gauge.
    final dialR = radius + stroke * 0.55;
    canvas.drawCircle(
      center,
      dialR,
      Paint()..color = dialFill.withValues(alpha: 0.70),
    );

    canvas.drawCircle(
      center,
      dialR,
      Paint()
        ..color = dialBorder.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (stroke * 0.55).clamp(6.0, 10.0),
    );

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // Color zones (car-like): OK -> WARN -> DANGER.
    const okEnd = 0.70;

    const warnEnd = 0.88;

    void arc(double a, double b, Color color) {
      if (b <= a) return;
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      final sa = startAngle + sweepAngle * a;
      final sw = sweepAngle * (b - a);
      canvas.drawArc(rect, sa, sw, false, p);
    }

    // Show zones subtly as a guide (the actual value is the filled arc).
    arc(0.0, okEnd, okColor.withValues(alpha: 0.22));
    arc(okEnd, warnEnd, warnColor.withValues(alpha: 0.24));
    arc(warnEnd, 1.0, dangerColor.withValues(alpha: 0.26));

    if (showNeedle) {
      Color colorAt(double t) {
        final tt = t.clamp(0.0, 1.0);
        if (tt <= okEnd) return okColor;
        if (tt <= warnEnd) return warnColor;
        return dangerColor;
      }

      // Fill the gauge up to the current value (no needle).
      final fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            okColor.withValues(alpha: 0.95),
            okColor.withValues(alpha: 0.95),
            warnColor.withValues(alpha: 0.95),
            dangerColor.withValues(alpha: 0.95),
          ],
          stops: const [0.0, okEnd, warnEnd, 1.0],
          // Keep gradient aligned with our arc start.
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle * clamped, false, fillPaint);

      // Light/glow effect: a soft outer glow along the filled arc + a brighter
      // "tip" highlight at the current value.
      final glowBaseColor = colorAt(clamped);

      final outerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.30
        ..strokeCap = StrokeCap.round
        ..color = glowBaseColor.withValues(alpha: 0.18)
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.outer,
          (stroke * 0.65).clamp(6.0, 12.0),
        );

      // Draw outer glow only for the filled part.
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle * clamped,
        false,
        outerGlowPaint,
      );

      // Brighter tip highlight for the last ~10% of the sweep.
      final tipFrom = (clamped - 0.10).clamp(0.0, clamped);
      final tipPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.05
        ..strokeCap = StrokeCap.round
        ..color = glowBaseColor.withValues(alpha: 0.55)
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          (stroke * 0.50).clamp(4.0, 10.0),
        );

      final tipStart = startAngle + sweepAngle * tipFrom;
      final tipSweep = sweepAngle * (clamped - tipFrom);
      if (tipSweep > 0) {
        canvas.drawArc(rect, tipStart, tipSweep, false, tipPaint);
      }
    }

    // Tick marks (denser, more automotive feel).
    final tickPaint = Paint()
      ..color = needle.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (stroke / 8).clamp(1.1, 2.0)
      ..strokeCap = StrokeCap.round;

    // 50 ticks: 10 major, 40 minor.
    for (int i = 0; i <= 50; i++) {
      final t = i / 50.0;
      final a = startAngle + sweepAngle * t;
      final isMajor = i % 5 == 0;
      final len = isMajor ? stroke * 0.72 : stroke * 0.36;
      final rOuter = radius + stroke * 0.16;
      final rInner = rOuter - len;
      final outer = Offset(
        center.dx + math.cos(a) * rOuter,
        center.dy + math.sin(a) * rOuter,
      );
      final inner = Offset(
        center.dx + math.cos(a) * rInner,
        center.dy + math.sin(a) * rInner,
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Numeric labels (0/20/40.. or 0/1/2..).
    if (labels.isNotEmpty) {
      final labelStyle = TextStyle(
        color: needle.withValues(alpha: 0.68),
        fontWeight: FontWeight.w800,
        fontSize: (stroke * 0.82).clamp(10.0, 14.0),
      );
      for (final l in labels) {
        final t = l.t.clamp(0.0, 1.0);
        final a = startAngle + sweepAngle * t;
        final rText = radius - stroke * 1.15;
        final pos = Offset(
          center.dx + math.cos(a) * rText,
          center.dy + math.sin(a) * rText,
        );

        final tp = TextPainter(
          text: TextSpan(text: l.text, style: labelStyle),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        canvas.save();
        canvas.translate(pos.dx - tp.width / 2, pos.dy - tp.height / 2);
        tp.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }

    // Small center hub for a more "instrument" look.
    canvas.drawCircle(
      center,
      (stroke / 2.4).clamp(5.0, 9.0),
      Paint()..color = dialFill.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      center,
      (stroke / 3.1).clamp(4.0, 7.0),
      Paint()..color = needle.withValues(alpha: 0.60),
    );
  }

  @override
  bool shouldRepaint(covariant _CarGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.showNeedle != showNeedle ||
        oldDelegate.background != background ||
        oldDelegate.needle != needle ||
        oldDelegate.okColor != okColor ||
        oldDelegate.warnColor != warnColor ||
        oldDelegate.dangerColor != dangerColor ||
        oldDelegate.dialFill != dialFill ||
        oldDelegate.dialBorder != dialBorder ||
        oldDelegate.labels != labels;
  }
}

class _SemiGaugePainter extends CustomPainter {
  _SemiGaugePainter({
    required this.value,
    required this.color,
    required this.background,
    required this.needle,
  });

  final double? value;
  final Color color;
  final Color background;
  final Color needle;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.height / 7).clamp(10.0, 18.0);
    final center = Offset(size.width / 2, size.height - stroke / 2);
    final radius = (size.height - stroke).clamp(0.0, double.infinity);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Draw the top semi-circle: from 180° to 360°.
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    final v = value;
    if (v != null && v.isFinite) {
      final clamped = v.clamp(0.0, 1.0);
      canvas.drawArc(rect, math.pi, math.pi * clamped, false, fgPaint);

      final angle = math.pi + math.pi * clamped;
      final needleLen = radius - stroke * 0.7;
      final end = Offset(
        center.dx + math.cos(angle) * needleLen,
        center.dy + math.sin(angle) * needleLen,
      );
      final needlePaint = Paint()
        ..color = needle.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (stroke / 5).clamp(2.0, 4.0)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(center, end, needlePaint);
      canvas.drawCircle(
        center,
        (stroke / 3).clamp(4.0, 7.0),
        Paint()..color = needle.withValues(alpha: 0.70),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.background != background ||
        oldDelegate.needle != needle;
  }
}

class _PercentFillTile extends StatelessWidget {
  const _PercentFillTile({
    required this.title,
    required this.icon,
    required this.percent,
    required this.suffix,
  });

  final String title;
  final IconData icon;
  final double? percent;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = (percent != null && percent!.isFinite)
        ? (percent! / 100).clamp(0.0, 1.0)
        : null;

    return _CardShell(
      child: Stack(
        children: [
          if (p != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: p,
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: Container(color: cs.primary.withValues(alpha: 0.20)),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                percent == null
                    ? '--'
                    : '${percent!.toStringAsFixed(0)}$suffix',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemperatureTile extends StatelessWidget {
  const _TemperatureTile({
    required this.title,
    required this.icon,
    required this.temperature,
    required this.unit,
    required this.min,
    required this.max,
    required this.warnAt,
    required this.dangerAt,
    required this.coldAt,
  });

  final String title;
  final IconData icon;
  final double? temperature;
  final String unit;

  final double min;
  final double max;
  final double warnAt;
  final double dangerAt;
  final double coldAt;

  String _prettyUnit(String u) {
    final trimmed = u.trim();
    if (trimmed == 'C') return '°C';
    if (trimmed == 'F') return '°F';
    return trimmed.isEmpty ? '°C' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final t = (temperature != null && temperature!.isFinite)
        ? temperature!
        : null;

    final normalized = (t != null && max != min)
        ? ((t - min) / (max - min)).clamp(0.0, 1.0)
        : null;

    Color accent() {
      if (t == null) return cs.onSurfaceVariant;
      if (t >= dangerAt) return cs.error;
      if (t >= warnAt) return cs.tertiary;
      if (t <= coldAt) return cs.secondary;
      return cs.primary;
    }

    final a = accent();
    final valueText = t == null ? '--' : t.toStringAsFixed(0);
    final unitText = _prettyUnit(unit);

    return _CardShell(
      child: Stack(
        children: [
          if (normalized != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: normalized,
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: Container(color: a.withValues(alpha: 0.18)),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: a.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: a, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                t == null ? '--' : '$valueText $unitText',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              if (t != null)
                Text(
                  '${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} $unitText',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FuelConsumptionSummaryTile extends StatelessWidget {
  const _FuelConsumptionSummaryTile({
    required this.instant,
    required this.average,
    required this.used,
    required this.idleUsed,
    required this.saved,
  });

  final OtherTileData instant;
  final OtherTileData average;
  final FuelTileData used;
  final FuelTileData idleUsed;
  final FuelTileData saved;

  String _cleanValue(InfoTileData data) {
    final v = data.formattedValue;
    if (v == '-.-') return '--';
    return v;
  }

  Widget _consumptionBlock(
    BuildContext context, {
    required String label,
    required InfoTileData data,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final valueText = _cleanValue(data);
    final full = data.unit.isEmpty ? valueText : '$valueText ${data.unit}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              full,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, {required InfoTileData data}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final valueText = _cleanValue(data);
    final full = data.unit.isEmpty ? valueText : '$valueText ${data.unit}';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                full,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_gas_station,
                  color: cs.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Spalanie',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _consumptionBlock(
                    context,
                    label: 'Chwilowe',
                    data: instant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _consumptionBlock(
                    context,
                    label: 'Średnie',
                    data: average,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat(context, data: used),
              const SizedBox(width: 10),
              _stat(context, data: idleUsed),
              const SizedBox(width: 10),
              _stat(context, data: saved),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeSummaryTile extends StatelessWidget {
  const _TimeSummaryTile({
    required this.totalSeconds,
    required this.idleSeconds,
    required this.continuousDriveSeconds,
    required this.overRpmSeconds,
    required this.underRpmSeconds,
  });

  final int totalSeconds;
  final int idleSeconds;
  final int continuousDriveSeconds;
  final int overRpmSeconds;
  final int underRpmSeconds;

  String _fmt(int seconds) {
    if (seconds < 0) return '--:--:--';
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  Widget _cell(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.timer, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Czas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'hh:mm:ss',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _cell(
                    context,
                    label: 'Całkowity',
                    value: _fmt(totalSeconds),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _cell(
                    context,
                    label: 'Postój',
                    value: _fmt(idleSeconds),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 62,
            child: _cell(
              context,
              label: 'Ciągła jazda',
              value: _fmt(continuousDriveSeconds),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 62,
            child: Row(
              children: [
                Expanded(
                  child: _cell(
                    context,
                    label: 'Wysokie RPM',
                    value: _fmt(overRpmSeconds),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _cell(
                    context,
                    label: 'Niskie RPM',
                    value: _fmt(underRpmSeconds),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DualScoreTile extends StatelessWidget {
  const _DualScoreTile({required this.eco, required this.smooth});

  final double eco;
  final double smooth;

  double? _scoreOrNull(double v) {
    if (!v.isFinite) return null;
    if (v < 0) return null;
    return v.clamp(0.0, 100.0);
  }

  Color _colorFor(BuildContext context, double v) {
    final cs = Theme.of(context).colorScheme;
    if (v < 40) return cs.error;
    if (v < 70) return cs.tertiary;
    return cs.primary;
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double? score,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final valueText = score == null ? '--' : score.toStringAsFixed(0);
    final progress = score == null ? null : (score / 100.0).clamp(0.0, 1.0);
    final color = score == null
        ? cs.onSurfaceVariant
        : _colorFor(context, score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              valueText,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (progress != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: color,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 12,
              color: cs.surfaceContainerHighest,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final ecoScore = _scoreOrNull(eco);
    final smoothScore = _scoreOrNull(smooth);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.insights, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ocena jazdy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '0–100',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(context, label: 'Eco', icon: Icons.eco, score: ecoScore),
          const SizedBox(height: 14),
          _row(context, label: 'Smooth', icon: Icons.waves, score: smoothScore),
        ],
      ),
    );
  }
}

class _TripMetricCard extends StatelessWidget {
  const _TripMetricCard({
    required this.title,
    required this.valueText,
    required this.unit,
    required this.icon,
  });

  factory _TripMetricCard.fromInfoTileData(
    InfoTileData data, {
    required IconData icon,
  }) {
    final unit = data.unit;
    final valueText = data.formattedValue;

    return _TripMetricCard(
      title: data.title,
      valueText: valueText,
      unit: unit,
      icon: icon,
    );
  }

  final String title;
  final String valueText;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
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
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cs.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              unit.isEmpty ? valueText : '$valueText $unit',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kafelek wyświetlający status systemu paliwowego
class _FuelSystemStatusTile extends StatelessWidget {
  const _FuelSystemStatusTile({required this.status});

  final FuelSystemStatus status;

  Color _statusColor(FuelSystemStatus status, ColorScheme cs) {
    switch (status) {
      case FuelSystemStatus.motorOff:
        return Colors.grey;
      case FuelSystemStatus.insufficientEngineTemp:
        return Colors.blue;
      case FuelSystemStatus.good:
        return Colors.green;
      case FuelSystemStatus.fuelCut:
        return Colors.orange;
      case FuelSystemStatus.systemFailure:
      case FuelSystemStatus.oxygenSensorFailure:
        return Colors.red;
      case FuelSystemStatus.unknown:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final statusColor = _statusColor(status, cs);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
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
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(status.icon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status paliwa',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status.description,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.fullDescription,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
}
