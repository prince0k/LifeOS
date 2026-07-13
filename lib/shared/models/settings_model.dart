import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 7)
class ShiftTemplateModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String workStart;

  @HiveField(2)
  final String workEnd;

  @HiveField(3)
  final String targetSleep;

  @HiveField(4)
  final int deepWorkTargetMinutes;

  ShiftTemplateModel({
    required this.name,
    required this.workStart,
    required this.workEnd,
    required this.targetSleep,
    required this.deepWorkTargetMinutes,
  });
}

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final Map<String, ShiftTemplateModel> shiftTemplates;

  @HiveField(1)
  final Map<String, double> recoveryWeights;

  @HiveField(2)
  final List<String> selectedAppPackages;

  @HiveField(3)
  final int unhealthyHabitCeiling;

  @HiveField(4)
  final int schemaVersion;

  SettingsModel({
    required this.shiftTemplates,
    required this.recoveryWeights,
    required this.selectedAppPackages,
    required this.unhealthyHabitCeiling,
    required this.schemaVersion,
  });
}
