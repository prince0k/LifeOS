import 'package:hive/hive.dart';
import 'detailed_smoking_log_model.dart';

part 'habit_log_model.g.dart';

@HiveType(typeId: 4)
class HabitLogModel extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final int smokingCount;

  @HiveField(2)
  final List<DetailedSmokingLogModel> detailedSmokingLogs;

  @HiveField(3)
  final int totalScreenTimeMinutes;

  @HiveField(4)
  final Map<String, int> appScreenTimes;

  HabitLogModel({
    required this.date,
    required this.smokingCount,
    required this.detailedSmokingLogs,
    required this.totalScreenTimeMinutes,
    required this.appScreenTimes,
  });
}
