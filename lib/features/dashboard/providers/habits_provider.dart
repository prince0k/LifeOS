import 'package:flutter/services.dart';
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
  final bool hasUsagePermission;
  final bool isInitialized;

  HabitsState({
    required this.waterCups,
    required this.cigaretteCount,
    required this.stepCount,
    required this.pornRecoveryDays,
    required this.totalScreenTime,
    required this.hasUsagePermission,
    required this.isInitialized,
  });

  HabitsState copyWith({
    int? waterCups,
    int? cigaretteCount,
    int? stepCount,
    int? pornRecoveryDays,
    int? totalScreenTime,
    bool? hasUsagePermission,
    bool? isInitialized,
  }) {
    return HabitsState(
      waterCups: waterCups ?? this.waterCups,
      cigaretteCount: cigaretteCount ?? this.cigaretteCount,
      stepCount: stepCount ?? this.stepCount,
      pornRecoveryDays: pornRecoveryDays ?? this.pornRecoveryDays,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      hasUsagePermission: hasUsagePermission ?? this.hasUsagePermission,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  final Ref _ref;
  static const _channel = MethodChannel('com.lifeos.lifeos/usage');

  HabitsNotifier(this._ref)
      : super(HabitsState(
          waterCups: 0,
          cigaretteCount: 0,
          stepCount: 0,
          pornRecoveryDays: 0,
          totalScreenTime: 0,
          hasUsagePermission: false,
          isInitialized: false,
        )) {
    _loadTodayHabits();
    refreshDigitalWellbeingScreenTime();
  }

  Future<void> _loadTodayHabits() async {
    final dbService = _ref.read(databaseServiceProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayLog = dbService.habitsLogBox.get(todayKey);
    bool permission = false;
    try {
      permission = await _channel.invokeMethod<bool>('checkUsagePermission') ?? false;
    } catch (_) {}

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
        hasUsagePermission: permission,
        isInitialized: true,
      );
    } else {
      state = HabitsState(
        waterCups: 0,
        cigaretteCount: 0,
        stepCount: 0,
        pornRecoveryDays: 0,
        totalScreenTime: 0,
        hasUsagePermission: permission,
        isInitialized: true,
      );
    }
  }

  Future<void> refreshDigitalWellbeingScreenTime() async {
    try {
      final isGranted = await _channel.invokeMethod<bool>('checkUsagePermission') ?? false;
      if (isGranted) {
        final totalMins = await _channel.invokeMethod<int>('getScreenTimeMinutes') ?? 0;
        if (totalMins > 0) {
          await updateHabit('screen_time', totalMins.toDouble());
        }
      }
    } catch (_) {}
  }

  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod<void>('grantUsagePermission');
      // Delay slightly to let screen transition occur before checking
      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadTodayHabits();
      await refreshDigitalWellbeingScreenTime();
    } catch (_) {}
  }

  Future<void> updateHabit(String habitName, double value) async {
    final dbService = _ref.read(databaseServiceProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final existingLog = dbService.habitsLogBox.get(todayKey);
    final HabitLogModel logToUpdate;

    if (existingLog != null) {
      final Map<String, int> updatedAppScreenTimes = Map.from(existingLog.appScreenTimes);
      int updatedSmokingCount = existingLog.smokingCount;
      int updatedScreenTime = existingLog.totalScreenTimeMinutes;

      if (habitName == 'cigarettes') {
        updatedSmokingCount = value.toInt().clamp(0, 99999);
      } else if (habitName == 'screen_time') {
        updatedScreenTime = value.toInt().clamp(0, 999999);
      } else {
        updatedAppScreenTimes[habitName] = value.toInt().clamp(0, 999999);
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
        smokingCount = value.toInt().clamp(0, 99999);
      } else if (habitName == 'screen_time') {
        screenTime = value.toInt().clamp(0, 999999);
      } else {
        appScreenTimes[habitName] = value.toInt().clamp(0, 999999);
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

  Future<void> incrementHabit(String habitName, int delta) async {
    int currentValue = 0;
    if (habitName == 'water') {
      currentValue = state.waterCups;
    } else if (habitName == 'cigarettes') {
      currentValue = state.cigaretteCount;
    } else if (habitName == 'steps') {
      currentValue = state.stepCount;
    } else if (habitName == 'porn_recovery') {
      currentValue = state.pornRecoveryDays;
    } else if (habitName == 'screen_time') {
      currentValue = state.totalScreenTime;
    }

    final targetValue = (currentValue + delta).clamp(0, 999999);
    await updateHabit(habitName, targetValue.toDouble());
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(ref);
});
