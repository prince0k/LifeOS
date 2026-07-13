import 'package:flutter/material.dart';
import '../../../../shared/models/recovery_state.dart';

class StateBanner extends StatelessWidget {
  final RecoveryState state;
  final VoidCallback? onOverrideTap;

  const StateBanner({
    super.key,
    required this.state,
    this.onOverrideTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColors = _getStateColors(state);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stateColors.primaryColor.withOpacity(0.85),
            stateColors.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: stateColors.primaryColor.withOpacity(0.3),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stateColors.title.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (onOverrideTap != null)
                TextButton(
                  onPressed: onOverrideTap,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.9),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  ),
                  child: const Text('Override'),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            stateColors.capacityLabel,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            stateColors.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  _StateColorSet _getStateColors(RecoveryState state) {
    switch (state) {
      case RecoveryState.burnoutRisk:
        return const _StateColorSet(
          title: 'Burnout Risk',
          capacityLabel: '0% Capacity Loaded',
          description: 'Mandatory Rest Day. All project tasks are hidden. Focus exclusively on sleep, hydration, and gentle recovery.',
          primaryColor: Color(0xFFDB4437), // Coral Red
        );
      case RecoveryState.overloaded:
        return const _StateColorSet(
          title: 'Overloaded',
          capacityLabel: '50% Capacity Loaded',
          description: 'Planner capacity is reduced. Suppressing secondary project cards. Mailing priority tasks remain highlighted.',
          primaryColor: Color(0xFFF4B400), // Orange
        );
      case RecoveryState.recovery:
        return const _StateColorSet(
          title: 'Recovery State',
          capacityLabel: '80% Capacity Loaded',
          description: 'Optional tasks hidden. Suggesting low-intensity administrative operations and recovery checks.',
          primaryColor: Color(0xFF4285F4), // Muted Blue
        );
      case RecoveryState.productive:
      default:
        return const _StateColorSet(
          title: 'Productive State',
          capacityLabel: '100% Capacity Loaded',
          description: 'Optimal state. Full timetable schedule loaded. Deep work focus triggers are highly recommended.',
          primaryColor: Color(0xFF0F9D58), // Green/Teal
        );
    }
  }
}

class _StateColorSet {
  final String title;
  final String capacityLabel;
  final String description;
  final Color primaryColor;

  const _StateColorSet({
    required this.title,
    required this.capacityLabel,
    required this.description,
    required this.primaryColor,
  });
}
