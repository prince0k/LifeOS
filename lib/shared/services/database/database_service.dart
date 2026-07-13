import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/settings_model.dart';
import '../../models/recovery_model.dart';
import '../../models/task_model.dart';
import '../../models/detailed_smoking_log_model.dart';
import '../../models/habit_log_model.dart';
import '../../models/project_model.dart';

class DatabaseService {
  final FlutterSecureStorage _secureStorage;
  
  late final Box<SettingsModel> _settingsBox;
  late final Box<RecoveryModel> _recoveryLogBox;
  late final Box<TaskModel> _tasksBox;
  late final Box<HabitLogModel> _habitsLogBox;
  late final Box<ProjectModel> _projectsBox;
  late final Box<String> _journalsBox;

  DatabaseService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Box<SettingsModel> get settingsBox => _settingsBox;
  Box<RecoveryModel> get recoveryLogBox => _recoveryLogBox;
  Box<TaskModel> get tasksBox => _tasksBox;
  Box<HabitLogModel> get habitsLogBox => _habitsLogBox;
  Box<ProjectModel> get projectsBox => _projectsBox;
  Box<String> get journalsBox => _journalsBox;

  // Compaction Strategy: Compact box if deleted entries exceed 50 and make up >30% of total
  bool _compactionStrategy(int entries, int deletedEntries) {
    return deletedEntries > 50 && (deletedEntries / entries) > 0.3;
  }

  Future<void> initialize({String? customPath}) async {
    // 1. Initialize Hive with documents directory
    final String hivePath;
    if (customPath != null) {
      hivePath = customPath;
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      hivePath = '${appDocumentDir.path}/hive';
    }
    Hive.init(hivePath);

    // 2. Fetch or Generate encryption key securely
    final encryptionKey = await _getOrCreateEncryptionKey();

    // 3. Register Type Adapters
    _registerAdapters();

    // 4. Open Unencrypted Boxes
    _settingsBox = await Hive.openBox<SettingsModel>(
      'settings_box',
      compactionStrategy: _compactionStrategy,
    );
    _tasksBox = await Hive.openBox<TaskModel>(
      'tasks_box',
      compactionStrategy: _compactionStrategy,
    );
    _projectsBox = await Hive.openBox<ProjectModel>(
      'projects_box',
      compactionStrategy: _compactionStrategy,
    );

    // 5. Open Encrypted Boxes
    final cipher = HiveAesCipher(encryptionKey);
    _recoveryLogBox = await Hive.openBox<RecoveryModel>(
      'recovery_log_box',
      encryptionCipher: cipher,
      compactionStrategy: _compactionStrategy,
    );
    _habitsLogBox = await Hive.openBox<HabitLogModel>(
      'habits_log_box',
      encryptionCipher: cipher,
      compactionStrategy: _compactionStrategy,
    );
    _journalsBox = await Hive.openBox<String>(
      'journals_box',
      encryptionCipher: cipher,
      compactionStrategy: _compactionStrategy,
    );
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    const keyName = 'hive_encryption_key';
    
    // Read key from device Keychain/Keystore
    final base64Key = await _secureStorage.read(key: keyName);
    
    if (base64Key == null) {
      // Key does not exist, generate new 256-bit secure key
      final newKey = Hive.generateSecureKey();
      final base64NewKey = base64Url.encode(newKey);
      await _secureStorage.write(key: keyName, value: base64NewKey);
      return Uint8List.fromList(newKey);
    } else {
      // Key exists, decode and return it
      return base64Url.decode(base64Key);
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ShiftTemplateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecoveryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(DetailedSmokingLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(HabitLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ProjectModelAdapter());
    }
  }

  Future<void> close() async {
    await Hive.close();
  }
}
