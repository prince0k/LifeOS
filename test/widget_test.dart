import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/main.dart';
import 'package:lifeos/shared/models/recovery_state.dart';
import 'package:lifeos/features/settings/providers/settings_provider.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'package:lifeos/features/dashboard/providers/tasks_provider.dart';
import 'package:lifeos/features/dashboard/providers/habits_provider.dart';
import 'package:lifeos/shared/models/settings_model.dart';

// Fake Notifier for Settings
class FakeSettingsNotifier extends Notifier<SettingsModel> implements SettingsNotifier {
  final SettingsModel _initialState;

  FakeSettingsNotifier(this._initialState);

  @override
  SettingsModel build() => _initialState;

  @override
  Future<void> updateSettings(SettingsModel newSettings) async {
    state = newSettings;
  }
}

// Fake Notifier for Recovery State
class FakeRecoveryNotifier extends Notifier<RecoveryStateData> implements RecoveryNotifier {
  final RecoveryStateData _initialState;

  FakeRecoveryNotifier(this._initialState);

  @override
  RecoveryStateData build() => _initialState;

  @override
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
  }) async {}

  @override
  Future<void> overrideState(RecoveryState newState) async {
    state = state.copyWith(activeState: newState);
  }
}

// Fake Notifier for Tasks
class FakeTasksNotifier extends StateNotifier<TasksState> implements TasksNotifier {
  final TasksState _initialState;

  FakeTasksNotifier(this._initialState) : super(_initialState);

  @override
  Future<void> addTask(String title, String priority) async {}

  @override
  Future<void> toggleTaskCompletion(String taskId) async {}

  @override
  Future<void> deleteTask(String taskId) async {}
}

// Fake Notifier for Habits
class FakeHabitsNotifier extends StateNotifier<HabitsState> implements HabitsNotifier {
  final HabitsState _initialState;

  FakeHabitsNotifier(this._initialState) : super(_initialState);

  @override
  Future<void> updateHabit(String habitName, double value) async {}

  @override
  Future<void> incrementHabit(String habitName, int delta) async {}

  @override
  Future<void> refreshDigitalWellbeingScreenTime() async {}

  @override
  Future<void> requestUsagePermission() async {}
}

void main() {
  testWidgets('LifeOS app renders Dashboard Screen with mock providers', (WidgetTester tester) async {
    final mockSettings = SettingsModel(
      shiftTemplates: {},
      recoveryWeights: {},
      selectedAppPackages: [],
      unhealthyHabitCeiling: 10,
      schemaVersion: 1,
    );

    final mockRecoveryState = RecoveryStateData(
      todayLog: null,
      activeState: RecoveryState.productive,
      isInitialized: true,
    );

    final mockTasksState = TasksState(
      todaysTasks: [],
      isInitialized: true,
    );

    final mockHabitsState = HabitsState(
      waterCups: 0,
      cigaretteCount: 0,
      stepCount: 0,
      pornRecoveryDays: 0,
      totalScreenTime: 0,
      hasUsagePermission: false,
      isInitialized: true,
    );

    // Build the app with overridden providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(() => FakeSettingsNotifier(mockSettings)),
          recoveryProvider.overrideWith(() => FakeRecoveryNotifier(mockRecoveryState)),
          tasksProvider.overrideWith((ref) => FakeTasksNotifier(mockTasksState)),
          habitsProvider.overrideWith((ref) => FakeHabitsNotifier(mockHabitsState)),
        ],
        child: const MyApp(),
      ),
    );

    // Pump frame
    await tester.pump();

    // Verify layout widgets are visible
    expect(find.text('LifeOS'), findsOneWidget);
    expect(find.text('Daily Check-in Pending'), findsOneWidget);
  });
}
