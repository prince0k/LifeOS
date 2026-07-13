import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/shared/models/recovery_state.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'widgets/recovery_gauge.dart';
import 'widgets/state_banner.dart';
import 'widgets/check_in_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recoveryState = ref.watch(recoveryProvider);

    final activeState = recoveryState.activeState;
    final todayLog = recoveryState.todayLog;
    final stateColor = _getStateColor(activeState);

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
              ],
              const SizedBox(height: 24.0),
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
