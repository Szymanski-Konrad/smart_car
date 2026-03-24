import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/ui/direction_tile.dart';
import 'package:smart_car/pages/live_data/ui/live_data_tile.dart';
import 'package:smart_car/utils/list_extension.dart';

class LiveStatsSection extends StatelessWidget {
  const LiveStatsSection({super.key, required this.state, required this.cubit});

  final LiveDataState state;
  final LiveDataCubit cubit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          runSpacing: 12.0,
          spacing: 12.0,
          children: [
            if (cubit.commands.isNotEmpty)
              Text(
                cubit.commands
                        .safeFirst<FuelSystemStatusCommand>()
                        ?.status
                        .fullDescription ??
                    '',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Strings.avgResponse(state.averageResponseTime)),
                Text(Strings.totalResponse(state.totalResponseTime)),
              ],
            ),
            DirectionTile(direction: state.direction, title: 'GPS'),
            DirectionTile(
              direction: state.driveDirection,
              scale: 1.2,
              title: 'Kierunek jazdy',
            ),
            if (cubit.commands.isNotEmpty)
              ...cubit.commands
                  .whereType<VisibleObdCommand>()
                  .map((command) => LiveDataTile(command: command))
                  ,
            if (state.errors.isNotEmpty)
              const SizedBox(width: double.infinity, height: 8),
            ...state.errors.map(
              (e) => ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
