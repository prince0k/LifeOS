import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/shared/models/recovery_state.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'package:lifeos/features/dashboard/providers/tasks_provider.dart';
import 'package:lifeos/shared/models/task_model.dart';
import 'widgets/recovery_gauge.dart';
import 'widgets/state_banner.dart';
import 'widgets/check_in_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recoveryState = ref.watch(recoveryProvider);
    final tasksState = ref.watch(tasksProvider);

    final activeState = recoveryState.activeState;
    final todayLog = recoveryState.todayLog;
    final stateColor = _getStateColor(activeState);
    final todaysTasks = tasksState.todaysTasks;
    final isBurnout = activeState == RecoveryState.burnoutRisk;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Dynamic State Banner Card
              StateBanner(
                state: activeState,
                onOverrideTap: () => _showOverrideSelector(context, ref),
              ),
              const SizedBox(height: 32.0),

              // 2. Conditional Score Render
              if (todayLog == null) ...[
                _buildPromptCard(context),
              ] else ...[
                // Gauge Display
                RecoveryGauge(
                  score: todayLog.computedRecoveryScore,
                  baseColor: stateColor,
                ),
                const SizedBox(height: 32.0),

                // Wellness Summary details
                _buildSummaryGrid(context, todayLog),

                // 3. Active Shift Timetable
                _buildScheduleTimeline(context, activeState, todayLog.shiftTemplateName ?? 'Morning Shift'),

                // 4. Tasks checklist
                _TaskPlannerSection(
                  tasks: todaysTasks,
                  isBurnout: isBurnout,
                ),
              ],
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.spa_outlined, size: 64.0, color: theme.colorScheme.primary),
          const SizedBox(height: 16.0),
          Text(
            'Daily Check-in Pending',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Check in to calculate your recovery index score and adapt today\'s planner capacity.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Start Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              onPressed: () => _showCheckInSheet(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, dynamic todayLog) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELLNESS SUMMARY',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.6,
          children: [
            _buildCardItem(context, 'Sleep Window', '${todayLog.sleepStartTime} - ${todayLog.sleepEndTime}', Icons.bedtime),
            _buildCardItem(context, 'Current Mood', todayLog.mood, Icons.sentiment_satisfied),
            _buildCardItem(context, 'Energy Score', '${todayLog.energyRating * 10}%', Icons.bolt),
            _buildCardItem(context, 'Stress Level', '${todayLog.stressRating * 10}%', Icons.psychology),
          ],
        ),
      ],
    );
  }

  Widget _buildCardItem(BuildContext context, String title, String val, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.0, color: theme.colorScheme.primary),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            val,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildScheduleTimeline(BuildContext context, RecoveryState activeState, String shiftName) {
    final theme = Theme.of(context);
    final isBurnout = activeState == RecoveryState.burnoutRisk;

    // Define timeline slots based on shift and state
    final List<Map<String, String>> slots;
    if (isBurnout) {
      slots = [
        {'time': 'All Day', 'title': '100% Recovery Focus', 'desc': 'All project tasks suppressed. Focus on sleep, light walking, and reflection.'},
      ];
    } else if (shiftName == 'Off Day') {
      slots = [
        {'time': 'All Day', 'title': 'Personal Off Day', 'desc': 'Free time, light recovery exercises, hobbies, and family time.'},
      ];
    } else if (shiftName == 'Night Shift') {
      slots = [
        {'time': '08:00 - 16:00', 'title': 'Rest & Recovery Sleep', 'desc': 'Sleep environment optimization.'},
        {'time': '16:00 - 21:00', 'title': 'Preparation & Personal Work', 'desc': 'Pre-work routines and planning.'},
        {'time': '21:00 - 05:00', 'title': 'Night Shift Duty', 'desc': 'Active deep work focus blocks.'},
        {'time': '05:00 - 08:00', 'title': 'Wind Down', 'desc': 'Relaxation routine before sleep.'},
      ];
    } else if (shiftName == '12-Hour Shift') {
      slots = [
        {'time': '07:00 - 19:00', 'title': '12-Hour Work Block', 'desc': 'Extended duty window. Pace energy expenditure.'},
        {'time': '19:00 - 22:30', 'title': 'Dinner & Relaxation', 'desc': 'Wind-down and family time.'},
        {'time': '22:30 - 06:30', 'title': 'Sleep Window', 'desc': 'Target 8 hours sleep.'},
      ];
    } else {
      // Default: Morning Shift
      slots = [
        {'time': '07:30 - 09:00', 'title': 'Morning Routine & Planning', 'desc': 'Review tasks and execute planning.'},
        {'time': '09:00 - 13:00', 'title': 'Deep Work Focus Block', 'desc': 'Target 240 minutes of deep focus.'},
        {'time': '13:00 - 14:00', 'title': 'Lunch & Hydration', 'desc': 'Mental break and nutrition.'},
        {'time': '14:00 - 17:00', 'title': 'Admin & Collaborations', 'desc': 'Emails, syncs, meetings, and follow-ups.'},
        {'time': '17:00 - 23:00', 'title': 'Personal Projects & Sleep Prep', 'desc': 'Physical habits checklist and wind-down.'},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE TIMETABLE: ${shiftName.toUpperCase()}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor,
              ),
            ),
            if (isBurnout)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SUPPRESSED',
                  style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            children: slots.map((slot) {
              final isLast = slot == slots.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time block
                    SizedBox(
                      width: 90,
                      child: Text(
                        slot['time']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Line indicator
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    // Title and desc
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot['title']!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            slot['desc']!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showCheckInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CheckInSheet(),
    );
  }

  void _showOverrideSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manual State Override',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Manually force a specific capacity load state regardless of the calculated score.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 20.0),
              ...RecoveryState.values.map((stateVal) {
                return ListTile(
                  title: Text(stateVal.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                  onTap: () {
                    ref.read(recoveryProvider.notifier).overrideState(stateVal);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _getStateColor(RecoveryState state) {
    switch (state) {
      case RecoveryState.burnoutRisk:
        return const Color(0xFFDB4437);
      case RecoveryState.overloaded:
        return const Color(0xFFF4B400);
      case RecoveryState.recovery:
        return const Color(0xFF4285F4);
      case RecoveryState.productive:
      default:
        return const Color(0xFF0F9D58);
    }
  }
}

class _TaskPlannerSection extends ConsumerStatefulWidget {
  final List<TaskModel> tasks;
  final bool isBurnout;

  const _TaskPlannerSection({
    required this.tasks,
    required this.isBurnout,
  });

  @override
  ConsumerState<_TaskPlannerSection> createState() => _TaskPlannerSectionState();
}

class _TaskPlannerSectionState extends ConsumerState<_TaskPlannerSection> {
  final _controller = TextEditingController();
  String _selectedPriority = 'Medium';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = widget.tasks;
    final isBurnout = widget.isBurnout;

    // Calculate Consistency Score
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final consistencyScore = tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S PLANNER',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor,
              ),
            ),
            if (tasks.isNotEmpty)
              Text(
                'Consistency: $consistencyScore%',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBurnout) ...[
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Burnout Risk State: All project tasks are suppressed to optimize full recovery.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No tasks scheduled for today. Add one below!',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) {
                            ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? theme.hintColor : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: TextStyle(
                                  color: _getPriorityColor(task.priority),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                ref.read(tasksProvider.notifier).deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const Divider(height: 24),
                // Task Input Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Add new task...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      underline: const SizedBox(),
                      items: ['High', 'Medium', 'Low'].map((priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPriority = val);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                      onPressed: () {
                        final title = _controller.text.trim();
                        if (title.isNotEmpty) {
                          ref.read(tasksProvider.notifier).addTask(title, _selectedPriority);
                          _controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }
}
