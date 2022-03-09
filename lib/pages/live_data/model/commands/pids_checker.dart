// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_car/app/resources/pids.dart';

part 'pids_checker.freezed.dart';

@freezed
class PidsChecker with _$PidsChecker {
  factory PidsChecker({
    @Default(true) bool pidsSupported1_20,
    @Default(false) bool pidsSupported21_40,
    @Default(false) bool pidsSupported41_60,
    @Default(false) bool pidsSupported61_80,
    @Default(false) bool pidsSupported81_A0,
    @Default(false) bool pidsSupportedA1_C0,
    @Default(false) bool pidsReaded1_20,
    @Default(false) bool pidsReaded21_40,
    @Default(false) bool pidsReaded41_60,
    @Default(false) bool pidsReaded61_80,
    @Default(false) bool pidsReaded81_A0,
    @Default(false) bool pidsReadedA1_C0,
  }) = _PidsChecker;
}

extension PidsCheckerExtension on PidsChecker {
  PidsChecker get firstPidsSupported => copyWith(pidsSupported1_20: true);
  PidsChecker get secondPidsSupported => copyWith(pidsSupported21_40: true);
  PidsChecker get thirdPidsSupported => copyWith(pidsSupported41_60: true);
  PidsChecker get fourthPidsSupported => copyWith(pidsSupported61_80: true);
  PidsChecker get fifthPidsSupported => copyWith(pidsSupported81_A0: true);
  PidsChecker get sixthPidsSupported => copyWith(pidsSupportedA1_C0: true);

  PidsChecker get firstPidsReaded => copyWith(pidsReaded1_20: true);
  PidsChecker get secondPidsReaded => copyWith(pidsReaded21_40: true);
  PidsChecker get thirdPidsReaded => copyWith(pidsReaded41_60: true);
  PidsChecker get fourthPidsReaded => copyWith(pidsReaded61_80: true);
  PidsChecker get fifthPidsReaded => copyWith(pidsReaded81_A0: true);
  PidsChecker get sixthPidsReaded => copyWith(pidsReadedA1_C0: true);

  String? get nextReadPidsPart {
    if (shouldRead1_20) return '01' + Pids.pidsList1;
    if (shouldRead21_40) return '01' + Pids.pidsList2;
    if (shouldRead41_60) return '01' + Pids.pidsList3;
    if (shouldRead61_80) return '01' + Pids.pidsList4;
    if (shouldRead81_A0) return '01' + Pids.pidsList5;
    if (shouldReadA1_C0) return '01' + Pids.pidsList6;
    return null;
  }

  bool get shouldRead1_20 => pidsSupported1_20 && !pidsReaded1_20;
  bool get shouldRead21_40 => pidsSupported21_40 && !pidsReaded21_40;
  bool get shouldRead41_60 => pidsSupported41_60 && !pidsReaded41_60;
  bool get shouldRead61_80 => pidsSupported61_80 && !pidsReaded61_80;
  bool get shouldRead81_A0 => pidsSupported81_A0 && !pidsReaded81_A0;
  bool get shouldReadA1_C0 => pidsSupportedA1_C0 && !pidsReadedA1_C0;
}
