import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/constants/activity_constants.dart';
import 'package:lifeos/features/recovery/providers/recovery_provider.dart';
import 'package:lifeos/features/dashboard/providers/habits_provider.dart';

class CheckInSheet extends ConsumerStatefulWidget {
  const CheckInSheet({super.key});

  @override
  ConsumerState<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<CheckInSheet> {
  String _selectedShiftTemplate = 'Morning Shift';
  String _sleepStart = '23:00';
  String _sleepEnd = '07:30';
  int _nightWakeUps = 0;
  int _sleepQuality = 3; // Good
  int _energyRating = 7;
  int _stressRating = 4;
  String _selectedMood = 'Peaceful';

  final List<String> _checkedPhysicalActivities = [];
  final List<String> _checkedMentalActivities = [];

  final List<String> _moods = ['Happy', 'Peaceful', 'Muted', 'Tired', 'Anxious', 'Stressed'];
  final List<String> _shiftTemplates = ['Morning Shift', 'Night Shift', '12-Hour Shift', 'Off Day', 'Night -> Morning Transition'];

  bool _isSyncing = false;

  Future<void> _syncGoogleFit() async {
    setState(() => _isSyncing = true);
    final data = await ref.read(recoveryProvider.notifier).fetchGoogleFitData();
    setState(() => _isSyncing = false);

    if (data != null) {
      setState(() {
        _sleepStart = data['sleepStart'] as String;
        _sleepEnd = data['sleepEnd'] as String;
        _energyRating = data['energyRating'] as int;
        _stressRating = data['stressRating'] as int;
      });

      final steps = data['steps'] as int;
      if (steps > 0) {
        ref.read(habitsProvider.notifier).updateHabit('steps', steps.toDouble());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Fit Synced! Steps: $steps, Sleep: $_sleepStart-$_sleepEnd, Heart Rate: ${data['heartRate']} bpm.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sync Google Fit data. Ensure permissions are granted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Wellness Check-in',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Google Fit Sync Button
            SizedBox(
              width: double.infinity,
              height: 44.0,
              child: OutlinedButton.icon(
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_alt, color: Colors.blue),
                label: Text(
                  _isSyncing ? 'Syncing Google Fit...' : 'Sync Google Fit & Vitals',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSyncing ? null : _syncGoogleFit,
              ),
            ),
            const SizedBox(height: 20.0),

            // 0. Active Shift Template Dropdown
            Text('Active Shift Template', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedShiftTemplate,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _shiftTemplates.map((shift) {
                return DropdownMenuItem<String>(
                  value: shift,
                  child: Text(shift),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedShiftTemplate = val);
              },
            ),
            const SizedBox(height: 20.0),

            // 1. Sleep Start & End Time Picker triggers
            Text('Sleep Window', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Sleep Time'),
                    subtitle: Text(_sleepStart),
                    trailing: const Icon(Icons.access_time),
                    tileColor: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ListTile(
                    title: const Text('Wake Time'),
                    subtitle: Text(_sleepEnd),
                    trailing: const Icon(Icons.access_time),
                    tileColor: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // 2. Night Wake-ups counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Night Wake-ups', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_nightWakeUps > 0) setState(() => _nightWakeUps--);
                      },
                    ),
                    Text('$_nightWakeUps', style: theme.textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _nightWakeUps++),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20.0),

            // 3. Sleep Quality mapping (1-4 slider)
            Text('Sleep Quality', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Slider(
              value: _sleepQuality.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: _getSleepQualityLabel(_sleepQuality),
              onChanged: (value) => setState(() => _sleepQuality = value.toInt()),
            ),
            Center(child: Text(_getSleepQualityLabel(_sleepQuality), style: theme.textTheme.bodyMedium)),
            const SizedBox(height: 24.0),

            // 4. Energy rating (1-10 slider)
            Text('Energy Rating', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Slider(
              value: _energyRating.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_energyRating',
              onChanged: (value) => setState(() => _energyRating = value.toInt()),
            ),
            Center(child: Text('Level: $_energyRating / 10', style: theme.textTheme.bodyMedium)),
            const SizedBox(height: 24.0),

            // 5. Stress rating (1-10 slider)
            Text('Stress Rating', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Slider(
              value: _stressRating.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_stressRating',
              onChanged: (value) => setState(() => _stressRating = value.toInt()),
            ),
            Center(child: Text('Level: $_stressRating / 10', style: theme.textTheme.bodyMedium)),
            const SizedBox(height: 24.0),

            // 6. Mood Chips
            Text('Current Mood', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMood = mood);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),

            // 7. Habits checklist
            Text('Wellness Checklist', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            ...ActivityConstants.checklistActivities.map((activity) {
              final isChecked = _checkedPhysicalActivities.contains(activity) ||
                                _checkedMentalActivities.contains(activity);
              return CheckboxListTile(
                title: Text(activity),
                value: isChecked,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      // Physical vs Mental splits (Arbitrary for calculation totals)
                      if (['Walk', 'Exercise', 'Stretching', 'Protein', 'Water'].contains(activity)) {
                        _checkedPhysicalActivities.add(activity);
                      } else {
                        _checkedMentalActivities.add(activity);
                      }
                    } else {
                      _checkedPhysicalActivities.remove(activity);
                      _checkedMentalActivities.remove(activity);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 32.0),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                onPressed: () async {
                  await ref.read(recoveryProvider.notifier).submitCheckIn(
                    sleepStartTime: _sleepStart,
                    sleepEndTime: _sleepEnd,
                    nightWakeUps: _nightWakeUps,
                    sleepQuality: _sleepQuality,
                    energyRating: _energyRating,
                    stressRating: _stressRating,
                    mood: _selectedMood,
                    checkedPhysicalActivities: _checkedPhysicalActivities,
                    checkedMentalActivities: _checkedMentalActivities,
                    currentShiftTemplateName: _selectedShiftTemplate,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? const TimeOfDay(hour: 23, minute: 0) : const TimeOfDay(hour: 7, minute: 30);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      final formattedHour = pickedTime.hour.toString().padLeft(2, '0');
      final formattedMin = pickedTime.minute.toString().padLeft(2, '0');
      setState(() {
        if (isStart) {
          _sleepStart = '$formattedHour:$formattedMin';
        } else {
          _sleepEnd = '$formattedHour:$formattedMin';
        }
      });
    }
  }

  String _getSleepQualityLabel(int quality) {
    switch (quality) {
      case 4:
        return 'Excellent';
      case 3:
        return 'Good';
      case 2:
        return 'Average';
      case 1:
      default:
        return 'Poor';
    }
  }
}
