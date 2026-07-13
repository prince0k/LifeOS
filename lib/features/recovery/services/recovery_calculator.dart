import '../../../shared/models/recovery_state.dart';

class RecoveryCalculator {
  /// Computes sleep duration in hours, taking wakeups penalty (15 mins each) into account.
  /// Handles sleep spanning midnight boundaries.
  double calculateSleepDuration({
    required String startTime, // "HH:MM"
    required String endTime,   // "HH:MM"
    required int nightWakeUps,
  }) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    
    if (startParts.length != 2 || endParts.length != 2) {
      throw ArgumentError('Time must be in HH:MM format');
    }

    final startHour = int.parse(startParts[0]);
    final startMin = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMin = int.parse(endParts[1]);

    final today = DateTime(2026, 7, 13);
    var startDateTime = DateTime(today.year, today.month, today.day, startHour, startMin);
    var endDateTime = DateTime(today.year, today.month, today.day, endHour, endMin);

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final durationDifference = endDateTime.difference(startDateTime);
    final totalMinutes = durationDifference.inMinutes - (nightWakeUps * 15);
    
    // Duration cannot be negative
    final result = totalMinutes / 60.0;
    return result < 0.0 ? 0.0 : result;
  }

  /// Computes Sleep component score (S, scale 0-100) using duration and quality ratings (1-4).
  double calculateSleepScore(double duration, int quality) {
    // 1. Duration Score (DS)
    final double durationScore;
    if (duration >= 8.0) {
      durationScore = 100.0;
    } else if (duration >= 7.0) {
      durationScore = 85.0;
    } else if (duration >= 6.0) {
      durationScore = 65.0;
    } else {
      durationScore = 40.0;
    }

    // 2. Quality Score (QS)
    final double qualityScore;
    switch (quality) {
      case 4: // Excellent
        qualityScore = 100.0;
        break;
      case 3: // Good
        qualityScore = 80.0;
        break;
      case 2: // Average
        qualityScore = 60.0;
        break;
      case 1: // Poor
      default:
        qualityScore = 30.0;
        break;
    }

    return (durationScore * 0.6) + (qualityScore * 0.4);
  }

  /// Computes Energy score component (E, scale 0-100) from user rating (1-10)
  double calculateEnergyScore(int rating) {
    final clampedRating = rating.clamp(1, 10);
    return clampedRating * 10.0;
  }

  /// Computes Stress score component (St, scale 0-100) from user rating (1-10)
  double calculateStressScore(int rating) {
    final clampedRating = rating.clamp(1, 10);
    return (11.0 - clampedRating) * 10.0;
  }

  /// Computes Habits checklist score component (H, scale 0-100) from completed items
  double calculateHabitsScore(int completedItemsCount, int totalItemsCount) {
    if (totalItemsCount <= 0) return 0.0;
    final ratio = completedItemsCount / totalItemsCount;
    return (ratio * 100.0).clamp(0.0, 100.0);
  }

  /// Returns modifier value based on shift template profiles
  double getShiftModifier(String shiftTemplateName) {
    switch (shiftTemplateName) {
      case 'Off Day':
        return 5.0;
      case 'Night Shift':
        return -10.0;
      case '12-Hour Shift':
        return -15.0;
      case 'Morning Shift':
      default:
        return 0.0;
    }
  }

  /// Calculates final Recovery Score (RS, 0-100)
  double calculateRecoveryScore({
    required double sleepComponent,
    required double energyComponent,
    required double stressComponent,
    required double habitsComponent,
    required double shiftModifier,
  }) {
    final rawScore = (sleepComponent * 0.40) +
                     (energyComponent * 0.25) +
                     (stressComponent * 0.25) +
                     (habitsComponent * 0.10) +
                     shiftModifier;
    return rawScore.clamp(0.0, 100.0);
  }

  /// Evaluates recovery state and transitions based on score thresholds and rules
  RecoveryState evaluateRecoveryState({
    required double currentScore,
    required List<double> pastScores, // pastScores[0] = yesterday, pastScores[1] = day before, etc.
    required RecoveryState previousState,
  }) {
    // RULE-RECOVERY-003: If in BurnoutRisk, escape only if currentScore >= 70
    if (previousState == RecoveryState.burnoutRisk) {
      if (currentScore >= 70.0) {
        return _getNormalState(currentScore);
      } else {
        return RecoveryState.burnoutRisk;
      }
    }

    // RULE-RECOVERY-003: Burnout Risk Escalation Rule (RS < 50 for three consecutive days)
    if (currentScore < 50.0 && pastScores.length >= 2 && pastScores[0] < 50.0 && pastScores[1] < 50.0) {
      return RecoveryState.burnoutRisk;
    }

    // Default range mappings
    return _getNormalState(currentScore);
  }

  RecoveryState _getNormalState(double score) {
    if (score < 40.0) {
      return RecoveryState.burnoutRisk;
    } else if (score < 60.0) {
      return RecoveryState.overloaded;
    } else if (score < 80.0) {
      return RecoveryState.recovery;
    } else {
      return RecoveryState.productive;
    }
  }
}
