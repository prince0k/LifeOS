import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lifeos/shared/services/database/database_service.dart';
import 'package:lifeos/shared/models/task_model.dart';
import 'package:lifeos/shared/models/recovery_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Pure Dart fake secure storage using dynamic dispatch to preserve compatibility
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
    tempDir = await Directory.systemTemp.createTemp('lifeos_database_test');
    mockSecureStorage = MockSecureStorage();
    databaseService = DatabaseService(secureStorage: mockSecureStorage);
  });

  tearDown(() async {
    await databaseService.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Database Service successfully initializes, generates keys, and writes/reads models', () async {
    await databaseService.initialize(customPath: tempDir.path);

    expect(databaseService.settingsBox.isOpen, isTrue);
    expect(databaseService.tasksBox.isOpen, isTrue);
    expect(databaseService.projectsBox.isOpen, isTrue);
    expect(databaseService.recoveryLogBox.isOpen, isTrue);
    expect(databaseService.habitsLogBox.isOpen, isTrue);
    expect(databaseService.journalsBox.isOpen, isTrue);

    final savedKey = await mockSecureStorage.read(key: 'hive_encryption_key');
    expect(savedKey, isNotNull);
    final keyBytes = base64Url.decode(savedKey!);
    expect(keyBytes.length, equals(32));

    final testTaskWarmup = TaskModel(
      id: 'task-warmup',
      title: 'Initialize repository warmup',
      priority: 'High',
      isCompleted: false,
      targetDate: '2026-07-13',
      rolloverCount: 0,
    );

    final testTask = TaskModel(
      id: 'task-123',
      title: 'Initialize repository',
      priority: 'High',
      isCompleted: false,
      targetDate: '2026-07-13',
      rolloverCount: 0,
    );

    // Warmup write using the separate instance to handle cold-start file allocation
    await databaseService.tasksBox.put(testTaskWarmup.id, testTaskWarmup);

    final stopwatchWrite = Stopwatch()..start();
    await databaseService.tasksBox.put(testTask.id, testTask);
    stopwatchWrite.stop();
    expect(stopwatchWrite.elapsedMilliseconds, lessThan(50));

    final stopwatchRead = Stopwatch()..start();
    final retrievedTask = databaseService.tasksBox.get(testTask.id);
    stopwatchRead.stop();
    expect(stopwatchRead.elapsedMilliseconds, lessThan(50));

    expect(retrievedTask, isNotNull);
    expect(retrievedTask!.title, equals('Initialize repository'));
    expect(retrievedTask.priority, equals('High'));

    final testRecovery = RecoveryModel(
      date: '2026-07-13',
      sleepStartTime: '23:00',
      sleepEndTime: '07:30',
      nightWakeUps: 1,
      sleepQuality: 3,
      energyRating: 8,
      stressRating: 4,
      mood: 'Happy',
      checkedPhysicalActivities: ['Walk completed'],
      checkedMentalActivities: ['Meditation completed'],
      computedRecoveryScore: 82.5,
      computedState: 'Productive',
    );

    await databaseService.recoveryLogBox.put(testRecovery.date, testRecovery);

    final retrievedRecovery = databaseService.recoveryLogBox.get(testRecovery.date);
    expect(retrievedRecovery, isNotNull);
    expect(retrievedRecovery!.computedRecoveryScore, equals(82.5));
    expect(retrievedRecovery.mood, equals('Happy'));
  });
}
