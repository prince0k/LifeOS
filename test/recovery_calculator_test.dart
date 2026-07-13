import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/recovery/services/recovery_calculator.dart';
import 'package:lifeos/shared/models/recovery_state.dart';

void main() {
  final calculator = RecoveryCalculator();

  group('Recovery Score Components Math Tests', () {
    test('calculateSleepDuration calculates midnight-spanning sleep and wakeups penalty correctly', () {
      // 23:00 to 07:00 = 8 hours. 1 wakeup = 15 mins penalty. Net duration = 7.75 hours.
      final duration = calculator.calculateSleepDuration(
        startTime: '23:00',
        endTime: '07:00',
        nightWakeUps: 1,
      );
      expect(duration, equals(7.75));

      // Same day sleep: 14:00 to 18:30 = 4.5 hours. 0 wakeups.
      final afternoonNap = calculator.calculateSleepDuration(
        startTime: '14:00',
        endTime: '18:30',
        nightWakeUps: 0,
      );
      expect(afternoonNap, equals(4.5));
    });

    test('calculateSleepScore maps sleep duration and quality correctly', () {
      // Duration >= 8 (100) and Quality Excellent (100) -> 100
      expect(calculator.calculateSleepScore(8.5, 4), equals(100.0));

      // Duration 7.5 (85) and Quality Average (60) -> 85*0.6 + 60*0.4 = 51 + 24 = 75
      expect(calculator.calculateSleepScore(7.5, 2), equals(75.0));

      // Duration < 6 (40) and Quality Poor (30) -> 40*0.6 + 30*0.4 = 24 + 12 = 36
      expect(calculator.calculateSleepScore(5.5, 1), equals(36.0));
    });

    test('calculateEnergyScore scales user rating to 0-100', () {
      expect(calculator.calculateEnergyScore(8), equals(80.0));
      expect(calculator.calculateEnergyScore(1), equals(10.0));
      expect(calculator.calculateEnergyScore(10), equals(100.0));
    });

    test('calculateStressScore scales user rating inversely to 0-100', () {
      // Stress rating 1 -> (11-1)*10 = 100
      expect(calculator.calculateStressScore(1), equals(100.0));
      
      // Stress rating 4 -> (11-4)*10 = 70
      expect(calculator.calculateStressScore(4), equals(70.0));

      // Stress rating 10 -> (11-10)*10 = 10
      expect(calculator.calculateStressScore(10), equals(10.0));
    });

    test('calculateHabitsScore returns correct completion percentage', () {
      expect(calculator.calculateHabitsScore(3, 9), closeTo(33.33, 0.01));
      expect(calculator.calculateHabitsScore(9, 9), equals(100.0));
      expect(calculator.calculateHabitsScore(0, 9), equals(0.0));
    });

    test('getShiftModifier maps shift profiles to penalty/bonus offsets', () {
      expect(calculator.getShiftModifier('Off Day'), equals(5.0));
      expect(calculator.getShiftModifier('Night Shift'), equals(-10.0));
      expect(calculator.getShiftModifier('12-Hour Shift'), equals(-15.0));
      expect(calculator.getShiftModifier('Morning Shift'), equals(0.0));
    });

    test('calculateRecoveryScore computes and clamps outputs safely', () {
      // Under high stress/poor sleep resulting in negative/clamped zero
      final lowScore = calculator.calculateRecoveryScore(
        sleepComponent: 30.0,
        energyComponent: 20.0,
        stressComponent: 10.0,
        habitsComponent: 0.0,
        shiftModifier: -15.0, // 12-Hour shift
      );
      // Raw: (30*0.4 + 20*0.25 + 10*0.25 + 0 + (-15)) = 12 + 5 + 2.5 - 15 = 4.5
      expect(lowScore, equals(4.5));

      // High recovery exceeding 100 with Off Day bonus -> clamped at 100
      final highScore = calculator.calculateRecoveryScore(
        sleepComponent: 100.0,
        energyComponent: 100.0,
        stressComponent: 100.0,
        habitsComponent: 100.0,
        shiftModifier: 5.0, // Off Day
      );
      expect(highScore, equals(100.0));
    });
  });

  group('Recovery Score State Transition Machine Tests', () {
    test('evaluateRecoveryState maps normal ranges correctly when no burnout applies', () {
      // RS >= 80 -> productive
      expect(
        calculator.evaluateRecoveryState(currentScore: 82.0, pastScores: [], previousState: RecoveryState.productive),
        equals(RecoveryState.productive),
      );

      // 60 <= RS < 80 -> recovery
      expect(
        calculator.evaluateRecoveryState(currentScore: 72.0, pastScores: [], previousState: RecoveryState.productive),
        equals(RecoveryState.recovery),
      );

      // 40 <= RS < 60 -> overloaded
      expect(
        calculator.evaluateRecoveryState(currentScore: 52.0, pastScores: [], previousState: RecoveryState.productive),
        equals(RecoveryState.overloaded),
      );

      // RS < 40 -> burnoutRisk
      expect(
        calculator.evaluateRecoveryState(currentScore: 38.0, pastScores: [], previousState: RecoveryState.productive),
        equals(RecoveryState.burnoutRisk),
      );
    });

    test('evaluateRecoveryState locks to BurnoutRisk on 3 consecutive days < 50', () {
      // Today: 48, Yesterday: 45, DayBefore: 49. (All < 50)
      final state = calculator.evaluateRecoveryState(
        currentScore: 48.0,
        pastScores: [45.0, 49.0],
        previousState: RecoveryState.overloaded,
      );
      // Normally 48.0 maps to overloaded, but consecutive rule forces burnoutRisk
      expect(state, equals(RecoveryState.burnoutRisk));

      // Today: 48, Yesterday: 45, DayBefore: 55. (Only 2 days < 50, does NOT trigger lock)
      final stateNormal = calculator.evaluateRecoveryState(
        currentScore: 48.0,
        pastScores: [45.0, 55.0],
        previousState: RecoveryState.overloaded,
      );
      expect(stateNormal, equals(RecoveryState.overloaded));
    });

    test('evaluateRecoveryState handles escaping from BurnoutRisk state', () {
      // 1. User is locked in burnoutRisk, today's score is 62.0 (Normally Recovery, but stays BurnoutRisk)
      final stateLocked = calculator.evaluateRecoveryState(
        currentScore: 62.0,
        pastScores: [45.0, 48.0],
        previousState: RecoveryState.burnoutRisk,
      );
      expect(stateLocked, equals(RecoveryState.burnoutRisk));

      // 2. User is locked in burnoutRisk, today's score is 70.0 (Escapes to normal state -> Recovery)
      final stateEscaped = calculator.evaluateRecoveryState(
        currentScore: 70.0,
        pastScores: [45.0, 48.0],
        previousState: RecoveryState.burnoutRisk,
      );
      expect(stateEscaped, equals(RecoveryState.recovery));

      // 3. User is locked in burnoutRisk, today's score is 85.0 (Escapes to normal state -> Productive)
      final stateFullyEscaped = calculator.evaluateRecoveryState(
        currentScore: 85.0,
        pastScores: [45.0, 48.0],
        previousState: RecoveryState.burnoutRisk,
      );
      expect(stateFullyEscaped, equals(RecoveryState.productive));
    });
  });
}
