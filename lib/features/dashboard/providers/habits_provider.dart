import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/habit_log_model.dart';
import '../../../shared/providers/database_provider.dart';

class HabitsState {
  final int waterCups;
  final int cigaretteCount;
  final int stepCount;
  final int pornRecoveryDays;
  final int totalScreenTime;
  final bool isInitialized;

  HabitsState({
    required this.waterCups,
    required this.cigaretteCount,
    required this.stepCount,
    required this.pornRecoveryDays,
    required this.totalScreenTime,
    required this.isInitialized,
  });

  HabitsState copyWith({
    int? waterCups,
    int? cigaretteCount,
    int? stepCount,
    int? pornRecoveryDays,
    int? totalScreenTime,
    bool? isInitialized,
  }) {
    return HabitsState(
      waterCups: waterCups ?? this.waterCups,
      cigaretteCount: cigaretteCount ?? this.cigaretteCount,
      stepCount: stepCount ?? this.stepCount,
      pornRecoveryDays: pornRecoveryDays ?? this.pornRecoveryDays,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  final Ref _ref;

  HabitsNotifier(this._ref)
      : super(HabitsState(
          waterCups: 0,
          cigaretteCount: 0,
          stepCount: 0,
          pornRecoveryDays: 0,
          totalScreenTime: 0,
          isInitialized: false,
        )) {
    _loadTodayHabits();
  }

  void _loadTodayHabits() {
    final dbService = _ref.read(databaseServiceProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayLog = dbService.habitsLogBox.get(todayKey);

    if (todayLog != null) {
      final water = todayLog.appScreenTimes['water'] ?? 0;
      final steps = todayLog.appScreenTimes['steps'] ?? 0;
      final pornRecovery = todayLog.appScreenTimes['porn_recovery'] ?? 0;

      state = HabitsState(
        waterCups: water,
        cigaretteCount: todayLog.smokingCount,
        stepCount: steps,
        pornRecoveryDays: pornRecovery,
        totalScreenTime: todayLog.totalScreenTimeMinutes,
        isInitialized: true,
      );
    } else {
      state = HabitsState(
        waterCups: 0,
        cigaretteCount: 0,
        stepCount: 0,
        pornRecoveryDays: 0,
        totalScreenTime: 0,
        isInitialized: true,
      );
    }
  }

  Future<void> incrementHabit(String habitName, int delta) async {
    final dbService = _ref.read(databaseServiceProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final existingLog = dbService.habitsLogBox.get(todayKey);
    final HabitLogModel logToUpdate;

    if (existingLog != null) {
      final Map<String, int> updatedAppScreenTimes = Map.from(existingLog.appScreenTimes);
      int updatedSmokingCount = existingLog.smokingCount;
      int updatedScreenTime = existingLog.totalScreenTimeMinutes;

      if (habitName == 'cigarettes') {
        updatedSmokingCount = (updatedSmokingCount + delta).clamp(0, 99999);
      } else if (habitName == 'screen_time') {
        updatedScreenTime = (updatedScreenTime + delta).clamp(0, 999999);
      } else {
        final currentVal = updatedAppScreenTimes[habitName] ?? 0;
        updatedAppScreenTimes[habitName] = (currentVal + delta).clamp(0, 999999);
      }

      logToUpdate = HabitLogModel(
        date: todayKey,
        smokingCount: updatedSmokingCount,
        detailedSmokingLogs: existingLog.detailedSmokingLogs,
        totalScreenTimeMinutes: updatedScreenTime,
        appScreenTimes: updatedAppScreenTimes,
      );
    } else {
      final Map<String, int> appScreenTimes = {};
      int smokingCount = 0;
      int screenTime = 0;

      if (habitName == 'cigarettes') {
        smokingCount = delta.clamp(0, 99999);
      } else if (habitName == 'screen_time') {
        screenTime = delta.clamp(0, 999999);
      } else {
        appScreenTimes[habitName] = delta.clamp(0, 999999);
      }

      logToUpdate = HabitLogModel(
        date: todayKey,
        smokingCount: smokingCount,
        detailedSmokingLogs: [],
        totalScreenTimeMinutes: screenTime,
        appScreenTimes: appScreenTimes,
      );
    }

    await dbService.habitsLogBox.put(todayKey, logToUpdate);
    _loadTodayHabits();
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(ref);
});
