import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/settings_model.dart';
import '../../../shared/providers/database_provider.dart';

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    final dbService = ref.read(databaseServiceProvider);
    final existingSettings = dbService.settingsBox.get('user_config');
    
    if (existingSettings != null) {
      return existingSettings;
    }
    
    // Scaffolding default settings if empty
    final defaultSettings = SettingsModel(
      shiftTemplates: {
        'Morning Shift': ShiftTemplateModel(
          name: 'Morning Shift',
          workStart: '10:30',
          workEnd: '18:30',
          targetSleep: '23:00',
          deepWorkTargetMinutes: 240, // 4 Hours
        ),
        'Night Shift': ShiftTemplateModel(
          name: 'Night Shift',
          workStart: '19:30',
          workEnd: '03:30',
          targetSleep: '04:00',
          deepWorkTargetMinutes: 180, // 3 Hours
        ),
        '12-Hour Shift': ShiftTemplateModel(
          name: '12-Hour Shift',
          workStart: '12:00',
          workEnd: '00:00',
          targetSleep: '00:30',
          deepWorkTargetMinutes: 0, // Recovery focused
        ),
        'Off Day': ShiftTemplateModel(
          name: 'Off Day',
          workStart: '00:00',
          workEnd: '00:00',
          targetSleep: '23:00',
          deepWorkTargetMinutes: 360, // 6 Hours
        ),
      },
      recoveryWeights: {
        'sleep': 0.40,
        'energy': 0.25,
        'stress': 0.25,
        'habits': 0.10,
      },
      selectedAppPackages: ['com.instagram.android', 'com.google.android.youtube'],
      unhealthyHabitCeiling: 10, // 10 cigarettes limit
      schemaVersion: 1,
    );

    // Save default config asynchronously
    dbService.settingsBox.put('user_config', defaultSettings);
    return defaultSettings;
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.settingsBox.put('user_config', newSettings);
    state = newSettings;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});
