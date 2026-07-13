import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/task_model.dart';
import '../../../shared/providers/database_provider.dart';

class TasksState {
  final List<TaskModel> todaysTasks;
  final bool isInitialized;

  TasksState({
    required this.todaysTasks,
    required this.isInitialized,
  });

  TasksState copyWith({
    List<TaskModel>? todaysTasks,
    bool? isInitialized,
  }) {
    return TasksState(
      todaysTasks: todaysTasks ?? this.todaysTasks,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final Ref _ref;

  TasksNotifier(this._ref) : super(TasksState(todaysTasks: [], isInitialized: false)) {
    _loadTasks();
  }

  void _loadTasks() {
    final dbService = _ref.read(databaseServiceProvider);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final allTasks = dbService.tasksBox.values.toList();
    final todaysTasks = allTasks.where((task) => task.targetDate == todayStr).toList();

    state = TasksState(
      todaysTasks: todaysTasks,
      isInitialized: true,
    );
  }

  Future<void> addTask(String title, String priority) async {
    final dbService = _ref.read(databaseServiceProvider);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    final newTask = TaskModel(
      id: taskId,
      title: title,
      priority: priority,
      isCompleted: false,
      targetDate: todayStr,
      rolloverCount: 0,
    );

    await dbService.tasksBox.put(taskId, newTask);
    _loadTasks();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final dbService = _ref.read(databaseServiceProvider);
    final task = dbService.tasksBox.get(taskId);

    if (task != null) {
      final updatedTask = TaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        priority: task.priority,
        isCompleted: !task.isCompleted,
        targetDate: task.targetDate,
        rolloverCount: task.rolloverCount,
        completedTimestamp: !task.isCompleted ? DateTime.now().toIso8601String() : null,
      );

      await dbService.tasksBox.put(taskId, updatedTask);
      _loadTasks();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.tasksBox.delete(taskId);
    _loadTasks();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(ref);
});
