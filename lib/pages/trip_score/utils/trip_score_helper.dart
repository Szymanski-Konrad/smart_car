import 'package:flutter/cupertino.dart';
import 'package:smart_car/models/trip_score_model.dart';

@immutable
abstract class TripScoreHelper {
  static double calculateScore({
    required TripScoreModel model,
    TripScoreModel? prevModel,
    double? prevScore,
  }) {
    double score = 50;

    // Check time off optimal RPM range
    final offRPMFactor =
        (model.overRPMDriveTime + model.underRPMDriveTime) / model.tripSeconds;
    if (offRPMFactor > 0.05) {
      score -= 10;
    } else {
      score += 5;
    }

    // Check how winding road is
    final totalTurns = model.leftTurns + model.rightTurns;
    final kmPerTurn = model.distance / totalTurns;
    if (kmPerTurn > 20) {
      score += 5;
    } else {
      score -= 5;
    }

    // Check rapid speed changes
    final totalRapidSpeedChanges =
        model.rapidAccelerations + model.rapidBreakings;
    final kmPerSpeedChange = model.distance / totalRapidSpeedChanges;
    if (kmPerSpeedChange > 20) {
      score += 5;
    } else {
      score -= 5;
    }

    if (prevModel != null) {
      if (model.avgFuelConsumption <= prevModel.avgFuelConsumption) {
        score += 2;
      } else {
        score -= 1;
      }

      if (model.savedFuel > prevModel.savedFuel) {
        score += 5;
      }

      if (model.idleFuel > prevModel.idleFuel) {
        score -= 10;
      }

      final prevOffRPMFactor =
          (prevModel.overRPMDriveTime + model.underRPMDriveTime) /
              prevModel.tripSeconds;
      if (prevOffRPMFactor > offRPMFactor) {
        score += 1;
      }
    }

    return score;
  }

  static void learn() async {}
}
