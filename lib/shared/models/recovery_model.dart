import 'package:hive/hive.dart';

part 'recovery_model.g.dart';

@HiveType(typeId: 2)
class RecoveryModel extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String sleepStartTime;

  @HiveField(2)
  final String sleepEndTime;

  @HiveField(3)
  final int nightWakeUps;

  @HiveField(4)
  final int sleepQuality;

  @HiveField(5)
  final int energyRating;

  @HiveField(6)
  final int stressRating;

  @HiveField(7)
  final String mood;

  @HiveField(8)
  final List<String> checkedPhysicalActivities;

  @HiveField(9)
  final List<String> checkedMentalActivities;

  @HiveField(10)
  final double computedRecoveryScore;

  @HiveField(11)
  final String computedState;

  @HiveField(12)
  final String? shiftTemplateName;

  RecoveryModel({
    required this.date,
    required this.sleepStartTime,
    required this.sleepEndTime,
    required this.nightWakeUps,
    required this.sleepQuality,
    required this.energyRating,
    required this.stressRating,
    required this.mood,
    required this.checkedPhysicalActivities,
    required this.checkedMentalActivities,
    required this.computedRecoveryScore,
    required this.computedState,
    this.shiftTemplateName = 'Morning Shift',
  });
}
