import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';

class SupportedPidsTile extends StatelessWidget {
  const SupportedPidsTile({
    Key? key,
    required this.checker,
  }) : super(key: key);

  final PidsChecker checker;

  static const yesStyle = TextStyle(color: Colors.green);
  static const noStyle = TextStyle(color: Colors.red);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      height: Constants.tileHeight,
      width: MediaQuery.of(context).size.width * 0.31,
      child: Column(
        children: [
          const Text('Is supported'),
          Text(
            'First ${checker.pidsReaded1_20 ? 'YES' : 0}',
            style: checker.pidsReaded1_20 ? yesStyle : noStyle,
          ),
          Text('Second ${checker.pidsReaded21_40 ? 'YES' : 0}',
              style: checker.pidsReaded21_40 ? yesStyle : noStyle),
          Text('Third ${checker.pidsReaded41_60 ? 'YES' : 0}',
              style: checker.pidsReaded41_60 ? yesStyle : noStyle),
          Text('Fourth ${checker.pidsReaded61_80 ? 'YES' : 0}',
              style: checker.pidsReaded61_80 ? yesStyle : noStyle),
          Text('Fifth ${checker.pidsReaded81_A0 ? 'YES' : 0}',
              style: checker.pidsReaded81_A0 ? yesStyle : noStyle),
          Text('Sixth ${checker.pidsReadedA1_C0 ? 'YES' : 0}',
              style: checker.pidsReadedA1_C0 ? yesStyle : noStyle),
        ],
      ),
    );
  }
}
