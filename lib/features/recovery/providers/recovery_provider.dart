import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/recovery_model.dart';
import '../../../shared/models/recovery_state.dart';
import '../../../shared/providers/database_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../services/recovery_calculator.dart';

class RecoveryStateData {
  final RecoveryModel? todayLog;
  final RecoveryState activeState;
  final bool isInitialized;

  RecoveryStateData({
    this.todayLog,
    required this.activeState,
    required this.isInitialized,
  });

  RecoveryStateData copyWith({
    RecoveryModel? todayLog,
    RecoveryState? activeState,
    bool? isInitialized,
  }) {
    return RecoveryStateData(
      todayLog: todayLog ?? this.todayLog,
      activeState: activeState ?? this.activeState,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class RecoveryNotifier extends Notifier<RecoveryStateData> {
  final _calculator = RecoveryCalculator();

  @override
  RecoveryStateData build() {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dbService = ref.read(databaseServiceProvider);
    
    final todayLog = dbService.recoveryLogBox.get(todayKey);
    final previousState = _getPreviousState(todayKey);

    if (todayLog != null) {
      // If checked in, resolve state from active score
      final pastScores = _getPastScores(todayKey);
      final activeState = _calculator.evaluateRecoveryState(
        currentScore: todayLog.computedRecoveryScore,
        pastScores: pastScores,
        previousState: previousState,
      );
      return RecoveryStateData(
        todayLog: todayLog,
        activeState: activeState,
        isInitialized: true,
      );
    }

    // Default state if no check-in exists yet
    return RecoveryStateData(
      todayLog: null,
      activeState: previousState,
      isInitialized: true,
    );
  }

  /// Submits today's recovery check-in details. Calculates scores and updates database.
  Future<void> submitCheckIn({
    required String sleepStartTime,
    required String sleepEndTime,
    required int nightWakeUps,
    required int sleepQuality,
    required int energyRating,
    required int stressRating,
    required String mood,
    required List<String> checkedPhysicalActivities,
    required List<String> checkedMentalActivities,
    required String currentShiftTemplateName,
  }) async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dbService = ref.read(databaseServiceProvider);
    final settings = ref.read(settingsProvider);

    // 1. Calculate components
    final sleepDuration = _calculator.calculateSleepDuration(
      startTime: sleepStartTime,
      endTime: sleepEndTime,
      nightWakeUps: nightWakeUps,
    );
    final sleepComponent = _calculator.calculateSleepScore(sleepDuration, sleepQuality);
    final energyComponent = _calculator.calculateEnergyScore(energyRating);
    final stressComponent = _calculator.calculateStressScore(stressRating);
    
    // Habits score checks completed checklist out of 9 total
    final completedCount = checkedPhysicalActivities.length + checkedMentalActivities.length;
    final habitsComponent = _calculator.calculateHabitsScore(completedCount, 9);
    
    final shiftModifier = _calculator.getShiftModifier(currentShiftTemplateName);

    // 2. Final recovery score
    final computedRecoveryScore = _calculator.calculateRecoveryScore(
      sleepComponent: sleepComponent,
      energyComponent: energyComponent,
      stressComponent: stressComponent,
      habitsComponent: habitsComponent,
      shiftModifier: shiftModifier,
    );

    final previousState = _getPreviousState(todayKey);
    final pastScores = _getPastScores(todayKey);
    
    final activeState = _calculator.evaluateRecoveryState(
      currentScore: computedRecoveryScore,
      pastScores: pastScores,
      previousState: previousState,
    );

    // 3. Persist check-in log
    final newLog = RecoveryModel(
      date: todayKey,
      sleepStartTime: sleepStartTime,
      sleepEndTime: sleepEndTime,
      nightWakeUps: nightWakeUps,
      sleepQuality: sleepQuality,
      energyRating: energyRating,
      stressRating: stressRating,
      mood: mood,
      checkedPhysicalActivities: checkedPhysicalActivities,
      checkedMentalActivities: checkedMentalActivities,
      computedRecoveryScore: computedRecoveryScore,
      computedState: activeState.name,
    );

    await dbService.recoveryLogBox.put(todayKey, newLog);

    state = state.copyWith(
      todayLog: newLog,
      activeState: activeState,
    );
  }

  /// Allows manual user override of the calculated recovery state (REQ-STATE-004)
  Future<void> overrideState(RecoveryState newState) async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dbService = ref.read(databaseServiceProvider);

    if (state.todayLog != null) {
      final updatedLog = RecoveryModel(
        date: state.todayLog!.date,
        sleepStartTime: state.todayLog!.sleepStartTime,
        sleepEndTime: state.todayLog!.sleepEndTime,
        nightWakeUps: state.todayLog!.nightWakeUps,
        sleepQuality: state.todayLog!.sleepQuality,
        energyRating: state.todayLog!.energyRating,
        stressRating: state.todayLog!.stressRating,
        mood: state.todayLog!.mood,
        checkedPhysicalActivities: state.todayLog!.checkedPhysicalActivities,
        checkedMentalActivities: state.todayLog!.checkedMentalActivities,
        computedRecoveryScore: state.todayLog!.computedRecoveryScore,
        computedState: newState.name,
      );
      await dbService.recoveryLogBox.put(todayKey, updatedLog);
      state = state.copyWith(
        todayLog: updatedLog,
        activeState: newState,
      );
    } else {
      state = state.copyWith(activeState: newState);
    }
  }

  List<double> _getPastScores(String todayKey) {
    final dbService = ref.read(databaseServiceProvider);
    final keys = dbService.recoveryLogBox.keys.cast<String>().toList();
    keys.remove(todayKey);
    keys.sort((a, b) => b.compareTo(a));
    
    return keys
        .map((k) => dbService.recoveryLogBox.get(k)?.computedRecoveryScore ?? 0.0)
        .toList();
  }

  RecoveryState _getPreviousState(String todayKey) {
    final dbService = ref.read(databaseServiceProvider);
    final keys = dbService.recoveryLogBox.keys.cast<String>().toList();
    keys.remove(todayKey);
    keys.sort((a, b) => b.compareTo(a));
    
    if (keys.isEmpty) return RecoveryState.productive;
    final lastLog = dbService.recoveryLogBox.get(keys.first);
    if (lastLog == null) return RecoveryState.productive;
    
    switch (lastLog.computedState) {
      case 'burnoutRisk':
        return RecoveryState.burnoutRisk;
      case 'overloaded':
        return RecoveryState.overloaded;
      case 'recovery':
        return RecoveryState.recovery;
      case 'productive':
      default:
        return RecoveryState.productive;
    }
  }
}

final recoveryProvider = NotifierProvider<RecoveryNotifier, RecoveryStateData>(() {
  return RecoveryNotifier();
});
