import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:smart_car/models/trip_score_model.dart';

@immutable
abstract class TripScoreHelper {
  static double calculateScore(TripScoreModel prevModel, TripScoreModel model) {
    double score = 50;

    // Check how winding road is
    final totalTurns = model.leftTurns + model.rightTurns;
    final kmPerTurn = model.distance / totalTurns;
    if (kmPerTurn > 30) {
      score += 5;
    } else {
      score -= 5;
    }

    // Check rapid speed changes
    final totalRapidSpeedChanges =
        model.rapidAccelerations + model.rapidBreakings;
    final kmPerSpeedChange = model.distance / totalRapidSpeedChanges;
    if (kmPerSpeedChange > 30) {
      score += 5;
    } else {
      score -= 5;
    }

    if (model.avgFuelConsumption < prevModel.avgFuelConsumption) {
      score += 1;
    } else {
      score -= 1;
    }

    if (model.savedFuel > prevModel.savedFuel) {
      score += 5;
    }

    if (model.idleFuel > prevModel.idleFuel) {
      score -= 10;
    }

    final random = Random();

    return score + random.nextInt(40) - 20;
  }
}
