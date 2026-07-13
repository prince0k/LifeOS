import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/shared/models/recovery_state.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'package:lifeos/features/dashboard/providers/tasks_provider.dart';
import 'package:lifeos/features/dashboard/providers/habits_provider.dart';
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
    final habitsState = ref.watch(habitsProvider);

    final activeState = recoveryState.activeState;
    final todayLog = recoveryState.todayLog;
    final stateColor = _getStateColor(activeState);
    final todaysTasks = tasksState.todaysTasks;
    final isBurnout = activeState == RecoveryState.burnoutRisk;

    // Apply adaptive rules to task planner
    final is12Hour = todayLog?.shiftTemplateName == '12-Hour Shift';
    final isTransition = todayLog?.shiftTemplateName == 'Night -> Morning Transition';
    final isPlannerSuppressed = isBurnout || is12Hour || isTransition;

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

                // Smart Recommendation Card
                _buildSmartRecommendation(context, activeState, todayLog.computedRecoveryScore, todayLog),
                const SizedBox(height: 32.0),

                // Wellness Summary details
                _buildSummaryGrid(context, todayLog),

                // Habits Quick Log Section
                _buildQuickLogSection(context, ref, habitsState),

                // Daily Minimum Wins Section
                _buildMinimumWinsSection(context, todayLog, todaysTasks, habitsState),

                // 3. Active Shift Timetable
                _buildScheduleTimeline(context, activeState, todayLog.shiftTemplateName ?? 'Morning Shift'),

                // 4. Tasks checklist
                _TaskPlannerSection(
                  tasks: todaysTasks,
                  isPlannerSuppressed: isPlannerSuppressed,
                  suppressionReason: isBurnout
                      ? 'Burnout Risk: All project tasks are suppressed.'
                      : (is12Hour
                          ? '12-Hour Shift Rules: No project work allowed today.'
                          : 'Transition Day: No Mailing/CityHost work allowed.'),
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

  Widget _buildSmartRecommendation(BuildContext context, RecoveryState state, double score, dynamic todayLog) {
    final theme = Theme.of(context);
    final String recommendation;
    final IconData icon;
    final Color cardBg;
    final Color textColor;

    final sleepDuration = _calculateSleepDuration(todayLog.sleepStartTime, todayLog.sleepEndTime);
    final isShortSleep = sleepDuration < 5.0;
    final is12Hour = todayLog.shiftTemplateName == '12-Hour Shift';
    final isTransition = todayLog.shiftTemplateName == 'Night -> Morning Transition';
    final isHighStress = todayLog.stressRating >= 8;

    if (state == RecoveryState.burnoutRisk) {
      recommendation = "⚠️ BURNOUT RISK ACTIVATE:\nAll project work is suppressed. Focus entirely on sleep, 20-min walks, and hydration. Log a Brain Dump to offload overthinking.";
      icon = Icons.health_and_safety;
      cardBg = Colors.red.withOpacity(0.08);
      textColor = Colors.red;
    } else if (isShortSleep) {
      recommendation = "⚠️ SLEEP < 5 HOURS (RECOVERY MODE):\nSleep was only ${sleepDuration.toStringAsFixed(1)} hours. Deep Work is reduced to 45-60 mins. CityHost tasks are optional today. Prioritize rest.";
      icon = Icons.warning_amber_rounded;
      cardBg = Colors.orange.withOpacity(0.08);
      textColor = Colors.orange;
    } else if (is12Hour) {
      recommendation = "🔴 12-HOUR SHIFT RULES:\nNo Mailing, No CityHost, No Deep Work today. Focus entirely on completing your shift, walk, meal prep, and getting sleep.";
      icon = Icons.timelapse;
      cardBg = Colors.red.withOpacity(0.08);
      textColor = Colors.red;
    } else if (isTransition) {
      recommendation = "⚡ NIGHT -> MORNING SHIFT TRANSITION:\nNo Mailing, No CityHost, No Deep Work today. Prioritize full recovery to shift your sleep schedule. Sleep early tonight.";
      icon = Icons.sync;
      cardBg = Colors.blue.withOpacity(0.08);
      textColor = Colors.blue;
    } else if (isHighStress) {
      recommendation = "⚠️ HIGH STRESS DETECTED:\nUrges and high stress logged. Workload reduced. Go for a walk, log a Brain Dump, and enable Recovery Mode.";
      icon = Icons.psychology;
      cardBg = Colors.orange.withOpacity(0.08);
      textColor = Colors.orange;
    } else if (score < 60) {
      recommendation = "💡 LOW RECOVERY SCORE ($score%):\nSuggest reducing deep work load. Limit screen time to under 3 hours. Focus on Mailing minimum wins.";
      icon = Icons.lightbulb_outline;
      cardBg = Colors.blue.withOpacity(0.08);
      textColor = Colors.blue;
    } else {
      recommendation = "🚀 PEAK PERFORMANCE LOADED:\nFull capacity active. Mailing dev and CityHost video editing recommended. Complete your 20-minute walk.";
      icon = Icons.rocket_launch_outlined;
      cardBg = Colors.green.withOpacity(0.08);
      textColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ADAPTIVE DECISION SUPPORT",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogSection(BuildContext context, WidgetRef ref, dynamic habitsState) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32.0),
        Text(
          'HABITS & QUICK LOG',
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
          childAspectRatio: 1.3,
          children: [
            // Cigarettes smoked Quick Log
            _buildHabitItem(
              context,
              title: 'Cigarettes',
              value: '${habitsState.cigaretteCount} smoked',
              icon: Icons.smoke_free,
              color: Colors.red,
              onTap: () {
                ref.read(habitsProvider.notifier).incrementHabit('cigarettes', 1);
              },
              actionLabel: '+1 Cigarette',
            ),
            // Water Intake Tracker
            _buildHabitItem(
              context,
              title: 'Water Intake',
              value: '${habitsState.waterCups} cups',
              icon: Icons.local_drink,
              color: Colors.blue,
              onTap: () {
                ref.read(habitsProvider.notifier).incrementHabit('water', 1);
              },
              actionLabel: '+1 Cup',
            ),
            // Steps log
            _buildHabitItem(
              context,
              title: 'Steps Walked',
              value: '${habitsState.stepCount} steps',
              icon: Icons.directions_walk,
              color: Colors.green,
              onTap: () {
                ref.read(habitsProvider.notifier).incrementHabit('steps', 1000);
              },
              actionLabel: '+1k Steps',
            ),
            // Porn Recovery Streak tracker
            _buildHabitItem(
              context,
              title: 'Porn Recovery',
              value: '${habitsState.pornRecoveryDays} days',
              icon: Icons.shield_moon_outlined,
              color: Colors.purple,
              onTap: () {
                ref.read(habitsProvider.notifier).incrementHabit('porn_recovery', 1);
              },
              actionLabel: '+1 Day',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHabitItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String actionLabel,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.dividerColor.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTap,
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumWinsSection(BuildContext context, dynamic todayLog, List<TaskModel> tasks, HabitsState habitsState) {
    final theme = Theme.of(context);

    final shiftCompleted = todayLog != null;
    final walkCompleted = todayLog.checkedPhysicalActivities.contains('Walk') || habitsState.stepCount >= 2000;
    final workCompleted = tasks.any((t) => t.isCompleted);
    final recoveryCheckIn = todayLog != null;
    final brainDumpCompleted = todayLog.checkedMentalActivities.contains('Brain Dump') || todayLog.checkedMentalActivities.contains('Journal');
    final screenTimeLimit = true; // Win met by default

    final wins = [
      {'title': 'Shift Completed', 'status': shiftCompleted},
      {'title': '20-Minute Walk', 'status': walkCompleted},
      {'title': '30 Mins Mailing/CityHost', 'status': workCompleted},
      {'title': 'Recovery Check-in', 'status': recoveryCheckIn},
      {'title': 'Brain Dump Before Sleep', 'status': brainDumpCompleted},
      {'title': 'Screen Time < 3 Hours', 'status': screenTimeLimit},
    ];

    final completedWins = wins.where((w) => w['status'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAILY MINIMUM WINS',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor,
              ),
            ),
            Text(
              '$completedWins / 6 MET',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: completedWins == 6 ? Colors.green : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            children: wins.map((win) {
              final isChecked = win['status'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isChecked ? Colors.green : theme.hintColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      win['title'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isChecked ? null : theme.hintColor,
                        fontWeight: isChecked ? FontWeight.bold : null,
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
        {'time': '08:30 AM', 'title': 'Wake Up', 'desc': 'Rise and prepare for walk.'},
        {'time': '08:30 - 09:00', 'title': 'Walk / Exercise', 'desc': 'Outdoor light cardio.'},
        {'time': '09:00 - 09:30', 'title': 'Breakfast', 'desc': 'Healthy nutrition.'},
        {'time': '09:30 - 11:30', 'title': 'Mailing Deep Work (2h)', 'desc': 'SEO, Dev, or website planning.'},
        {'time': '11:30 - 11:45', 'title': 'Break', 'desc': 'Relaxation block.'},
        {'time': '11:45 - 01:15', 'title': 'CityHost Deep Work (1.5h)', 'desc': 'Video editing or website campaigns.'},
        {'time': '01:15 - 02:00', 'title': 'Lunch', 'desc': 'Mental break.'},
        {'time': '02:00 - 03:00', 'title': 'Home / Personal Work', 'desc': 'Desk organizing, chores.'},
        {'time': '03:00 - 03:30', 'title': 'English Practice', 'desc': 'Daily practice.'},
        {'time': '03:30 - 04:30', 'title': 'Weekly Review + Planning', 'desc': 'Calendar, logs, targets review.'},
        {'time': '04:30 - 05:30', 'title': 'Walk / Exercise', 'desc': 'Cardio recovery walk.'},
        {'time': '05:30 - 06:30', 'title': 'Learning / Reading', 'desc': 'Book reading, research.'},
        {'time': '06:30 - 07:30', 'title': 'Family / Free Time', 'desc': 'Social connection.'},
        {'time': '09:30 - 10:00', 'title': 'Brain Dump + Journal', 'desc': 'Clear thoughts before bed.'},
        {'time': '10:30 PM', 'title': 'Sleep', 'desc': 'Wind down (Bed rules active).'},
      ];
    } else if (shiftName == 'Night Shift') {
      slots = [
        {'time': '11:00 AM', 'title': 'Wake Up', 'desc': 'Rise and hydrate.'},
        {'time': '11:00 - 11:20', 'title': 'Water + Breakfast', 'desc': 'First meal of the day.'},
        {'time': '11:20 - 11:45', 'title': 'Walk', 'desc': 'Light outdoor walk.'},
        {'time': '11:45 - 12:00', 'title': 'Recovery Check-in', 'desc': 'Log sleep and stats.'},
        {'time': '12:00 - 02:00', 'title': 'Mailing Deep Work (2h)', 'desc': 'Focus on web or SEO.'},
        {'time': '02:00 - 02:30', 'title': 'Lunch', 'desc': 'Nutritional break.'},
        {'time': '02:30 - 03:30', 'title': 'CityHost Work (1h)', 'desc': 'Video edits or marketing.'},
        {'time': '03:30 - 04:00', 'title': 'English Practice', 'desc': 'Focus and study.'},
        {'time': '04:00 - 04:45', 'title': 'Power Nap', 'desc': 'Prepare energy for shift.'},
        {'time': '05:00 - 05:30', 'title': 'Dinner', 'desc': 'Fuel up.'},
        {'time': '05:30 - 06:45', 'title': 'Planning / Small Tasks', 'desc': 'Quick items.'},
        {'time': '07:30 - 03:30', 'title': 'Shift Duty', 'desc': 'Work shifts (Idle: SEO, planning).'},
        {'time': '03:30 - 03:45', 'title': 'Shutdown Ritual', 'desc': 'No phone, walk, change clothes.'},
        {'time': '04:00 AM', 'title': 'Sleep', 'desc': 'Fast asleep.'},
      ];
    } else if (shiftName == '12-Hour Shift') {
      slots = [
        {'time': '09:30 AM', 'title': 'Wake Up', 'desc': 'Rise and prepare.'},
        {'time': '09:30 - 09:50', 'title': 'Walk', 'desc': 'Sunlight exposure.'},
        {'time': '09:50 - 10:20', 'title': 'Breakfast', 'desc': 'Fuel for shift.'},
        {'time': '10:20 - 10:35', 'title': 'Recovery Check-in', 'desc': 'Log check-in parameters.'},
        {'time': '10:35 - 11:45', 'title': 'Personal Work / Meal Prep', 'desc': 'Preparations.'},
        {'time': '12:00 - 00:00', 'title': '12-Hour Shift Duty', 'desc': 'Work shift (Idle: Reading, planning).'},
        {'time': '00:00 - 00:15', 'title': 'Shutdown Ritual', 'desc': 'Signal brain work ended.'},
        {'time': '00:30 AM', 'title': 'Sleep', 'desc': 'Deep rest.'},
      ];
    } else if (shiftName == 'Night -> Morning Transition') {
      slots = [
        {'time': '03:45 AM', 'title': 'Sleep', 'desc': 'Rest after night shift.'},
        {'time': '09:15 AM', 'title': 'Wake Up', 'desc': 'Transition wake window.'},
        {'time': '09:15 - 09:30', 'title': 'Water + Stretch', 'desc': 'Light movement.'},
        {'time': '09:30 - 10:15', 'title': 'Breakfast', 'desc': 'Nutritional fueling.'},
        {'time': '10:30 - 18:30', 'title': 'Morning Shift (Transition)', 'desc': 'Light tasks during shift.'},
        {'time': '18:30 - 19:00', 'title': 'Dinner', 'desc': 'Post-shift meal.'},
        {'time': '19:00 - 21:30', 'title': 'Recovery Block', 'desc': 'No project work. Relax.'},
        {'time': '21:30 - 22:00', 'title': 'Brain Dump', 'desc': 'Empty thoughts.'},
        {'time': '22:30 PM', 'title': 'Sleep', 'desc': 'Align sleep cycle early.'},
      ];
    } else {
      // Default: Morning Shift
      slots = [
        {'time': '08:30 AM', 'title': 'Wake Up', 'desc': 'Rise (No phone in bed).'},
        {'time': '08:30 - 08:45', 'title': 'Water + Freshen Up', 'desc': 'Hydrate.'},
        {'time': '08:45 - 09:10', 'title': 'Walk + Sunlight', 'desc': 'Circadian rhythm setup.'},
        {'time': '09:10 - 09:40', 'title': 'Breakfast', 'desc': 'Fueling up.'},
        {'time': '09:40 - 10:00', 'title': 'Recovery Check-in + Planning', 'desc': 'Determine daily goals.'},
        {'time': '10:00 - 10:25', 'title': 'Prepare for Shift', 'desc': 'Desk setup separation.'},
        {'time': '10:30 - 18:30', 'title': 'Morning Shift Duty', 'desc': 'Shift work (Idle: SEO, planning).'},
        {'time': '18:30 - 18:45', 'title': 'Shutdown Ritual', 'desc': 'Leave desk, walk 5-10m.'},
        {'time': '18:45 - 20:45', 'title': 'Mailing Deep Work (2h)', 'desc': 'SEO, Dev, social media.'},
        {'time': '20:45 - 21:15', 'title': 'Dinner', 'desc': 'Healthy break.'},
        {'time': '21:15 - 22:15', 'title': 'CityHost Work (1h)', 'desc': 'Video editing, website.'},
        {'time': '22:15 - 22:35', 'title': 'English Practice', 'desc': 'Daily exercises.'},
        {'time': '22:35 - 22:50', 'title': 'Brain Dump + Journal', 'desc': 'Offload mental logs.'},
        {'time': '23:00 PM', 'title': 'Sleep', 'desc': 'Wind down (Bed rules active).'},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TIMETABLE: ${shiftName.toUpperCase()}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.hintColor,
                ),
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

  double _calculateSleepDuration(String start, String end) {
    try {
      final startParts = start.split(':');
      final endParts = end.split(':');
      final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      var endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (endMin < startMin) {
        endMin += 24 * 60; // Midnight cross
      }
      return (endMin - startMin) / 60.0;
    } catch (_) {
      return 8.0;
    }
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
  final bool isPlannerSuppressed;
  final String suppressionReason;

  const _TaskPlannerSection({
    required this.tasks,
    required this.isPlannerSuppressed,
    required this.suppressionReason,
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
    final isPlannerSuppressed = widget.isPlannerSuppressed;

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
              if (isPlannerSuppressed) ...[
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        widget.suppressionReason,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
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
