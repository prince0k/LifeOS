import 'package:hive/hive.dart';

part 'detailed_smoking_log_model.g.dart';

@HiveType(typeId: 5)
class DetailedSmokingLogModel extends HiveObject {
  @HiveField(0)
  final String timestamp;

  @HiveField(1)
  final String trigger;

  @HiveField(2)
  final String mood;

  @HiveField(3)
  final String notes;

  DetailedSmokingLogModel({
    required this.timestamp,
    required this.trigger,
    required this.mood,
    required this.notes,
  });
}
