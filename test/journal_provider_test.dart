import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lifeos/shared/services/database/database_service.dart';
import 'package:lifeos/shared/providers/database_provider.dart';
import 'package:lifeos/features/notes/providers/journal_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock secure storage
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
    tempDir = await Directory.systemTemp.createTemp('lifeos_journal_provider_test');
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

  test('JournalProvider save and read daily reflections test', () async {
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(databaseService),
      ],
    );

    // 1. Verify default state is empty
    final initialJournals = container.read(journalProvider);
    expect(initialJournals.isEmpty, isTrue);

    // 2. Save reflection for today
    const dateKey = '2026-07-13';
    const journalText = 'Great WFH morning shift, completed SEO research and walk.';
    await container.read(journalProvider.notifier).saveJournal(dateKey, journalText);

    // 3. Verify it is loaded in the state
    final savedJournals = container.read(journalProvider);
    expect(savedJournals.containsKey(dateKey), isTrue);
    expect(savedJournals[dateKey], equals(journalText));

    // 4. Verify it was written to Hive Box
    expect(databaseService.journalsBox.get(dateKey), equals(journalText));

    // 5. Save empty string (should trigger delete)
    await container.read(journalProvider.notifier).saveJournal(dateKey, '');
    final deletedJournals = container.read(journalProvider);
    expect(deletedJournals.containsKey(dateKey), isFalse);
    expect(databaseService.journalsBox.containsKey(dateKey), isFalse);
  });
}
