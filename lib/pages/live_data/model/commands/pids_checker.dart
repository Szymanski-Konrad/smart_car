// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

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
}
