import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lifeos/shared/services/database/database_service.dart';
import 'package:lifeos/shared/providers/database_provider.dart';
import 'package:lifeos/shared/models/recovery_state.dart';
import 'package:lifeos/features/settings/providers/settings_provider.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Dynamic mock secure storage
class MockSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #read) {
      final String key = invocation.namedArguments[const Symbol('key')] as String;
      return Future.value(_storage[key]);
    }
    if (invocation.memberName == #write) {
      final String key = invocation.namedArguments[const Symbol('key')] as String;
      final String? value = invocation.namedArguments[const Symbol('value')] as String?;
      if (value == null) {
        _storage.remove(key);
      } else {
        _storage[key] = value;
      }
      return Future.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late Directory tempDir;
  late MockSecureStorage mockSecureStorage;
  late DatabaseService databaseService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lifeos_dashboard_provider_test');
    mockSecureStorage = MockSecureStorage();
    databaseService = DatabaseService(secureStorage: mockSecureStorage);
    await databaseService.initialize(customPath: tempDir.path);
  });

  tearDown(() async {
    await databaseService.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('SettingsProvider and RecoveryProvider lifecycle tests', () async {
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(databaseService),
      ],
    );

    // 1. Verify Settings Provider builds and saves default config
    final settings = container.read(settingsProvider);
    expect(settings.schemaVersion, equals(1));
    expect(settings.shiftTemplates.containsKey('Morning Shift'), isTrue);
    expect(settings.shiftTemplates['Morning Shift']!.deepWorkTargetMinutes, equals(240));

    // 2. Verify Recovery Provider defaults to productive if no logs exist
    final initialRecoveryState = container.read(recoveryProvider);
    expect(initialRecoveryState.todayLog, isNull);
    expect(initialRecoveryState.activeState, equals(RecoveryState.productive));

    // 3. Submit Check-In
    await container.read(recoveryProvider.notifier).submitCheckIn(
      sleepStartTime: '23:00',
      sleepEndTime: '07:00',
      nightWakeUps: 0,
      sleepQuality: 4, // Excellent (100)
      energyRating: 9, // 90
      stressRating: 2, // (11-2)*10 = 90
      mood: 'Focused',
      checkedPhysicalActivities: ['Walk', 'Exercise', 'Water'], // 3 items
      checkedMentalActivities: ['Journal', 'Meditation'],       // 2 items -> 5 items total (5/9 * 100 = 55.5)
      currentShiftTemplateName: 'Morning Shift', // modifier = 0
    );

    final submittedState = container.read(recoveryProvider);
    expect(submittedState.todayLog, isNotNull);
    // Score expected: S=100*0.4=40; E=90*0.25=22.5; St=90*0.25=22.5; H=55.5*0.1=5.5 -> Total = 40+22.5+22.5+5.5 = 90.5
    expect(submittedState.todayLog!.computedRecoveryScore, closeTo(90.5, 0.1));
    expect(submittedState.activeState, equals(RecoveryState.productive));

    // 4. Test Manual Override
    await container.read(recoveryProvider.notifier).overrideState(RecoveryState.overloaded);
    final overriddenState = container.read(recoveryProvider);
    expect(overriddenState.activeState, equals(RecoveryState.overloaded));
    expect(overriddenState.todayLog!.computedState, equals('overloaded'));
  });
}
