import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? projectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String targetDate;

  @HiveField(6)
  final int rolloverCount;

  @HiveField(7)
  final String? completedTimestamp;

  TaskModel({
    required this.id,
    this.projectId,
    required this.title,
    required this.priority,
    required this.isCompleted,
    required this.targetDate,
    required this.rolloverCount,
    this.completedTimestamp,
  });
}
