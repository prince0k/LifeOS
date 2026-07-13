import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 6)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double weeklyTargetHours;

  @HiveField(4)
  final String creationTimestamp;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.weeklyTargetHours,
    required this.creationTimestamp,
  });
}
