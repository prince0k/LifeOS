import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../../dashboard/providers/tasks_provider.dart';

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Dump & Journal', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          tabs: const [
            Tab(text: 'Brain Dump', icon: Icon(Icons.psychology_outlined)),
            Tab(text: 'Daily Reflection', icon: Icon(Icons.auto_stories_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BrainDumpView(),
          _JournalView(),
        ],
      ),
    );
  }
}

class _BrainDumpView extends ConsumerStatefulWidget {
  const _BrainDumpView();

  @override
  ConsumerState<_BrainDumpView> createState() => _BrainDumpViewState();
}

class _BrainDumpViewState extends ConsumerState<_BrainDumpView> {
  final _textController = TextEditingController();
  final List<Map<String, dynamic>> _parsedItems = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parseText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final lines = text.split('\n');
    setState(() {
      _parsedItems.clear();
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          _parsedItems.add({
            'text': trimmed,
            'priority': 'Medium',
            'project': 'Personal',
          });
        }
      }
    });
  }

  void _addTasksToPlanner() {
    if (_parsedItems.isEmpty) return;

    for (var item in _parsedItems) {
      final String projectTag = item['project'] == 'Personal' ? '' : '[${item['project']}] ';
      final String taskTitle = '$projectTag${item['text']}';
      ref.read(tasksProvider.notifier).addTask(taskTitle, item['priority'] as String);
    }

    setState(() {
      _parsedItems.clear();
      _textController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tasks added successfully to today\'s planner!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVENING BRAIN DUMP',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Write down any pending tasks, thoughts, or worries here to clear your mind before sleeping.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Type thoughts line-by-line...\ne.g. Buy milk\nResearch mailing project SEO keywords\nSetup video editing campaign',
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_textController.text.isNotEmpty || _parsedItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _parsedItems.clear();
                      _textController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.bolt, size: 16),
                label: const Text('Parse Thoughts', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _parseText,
              ),
            ],
          ),
          if (_parsedItems.isNotEmpty) ...[
            const SizedBox(height: 24.0),
            Text(
              'CONVERT TO TASKS',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parsedItems.length,
              itemBuilder: (context, index) {
                final item = _parsedItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['text'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          // Project Tag selection
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: item['project'] as String,
                              decoration: const InputDecoration(
                                labelText: 'Project',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: ['Mailing', 'CityHost', 'Personal'].map((proj) {
                                return DropdownMenuItem(value: proj, child: Text(proj));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => item['project'] = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Priority level selection
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: item['priority'] as String,
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: ['High', 'Medium', 'Low'].map((pri) {
                                return DropdownMenuItem(value: pri, child: Text(pri));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => item['priority'] = val);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _parsedItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text('Add selected to Today\'s Planner', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _addTasksToPlanner,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _JournalView extends ConsumerStatefulWidget {
  const _JournalView();

  @override
  ConsumerState<_JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends ConsumerState<_JournalView> {
  final _journalController = TextEditingController();
  final String _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRef = ref.read(journalProvider)[_todayKey] ?? '';
      _journalController.text = currentRef;
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _saveReflection() {
    final text = _journalController.text.trim();
    ref.read(journalProvider.notifier).saveJournal(_todayKey, text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text.isEmpty ? 'Reflection deleted!' : 'Reflection saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journals = ref.watch(journalProvider);

    // Filter past journals
    final pastJournals = journals.entries
        .where((e) => e.key != _todayKey)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S REFLECTION',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Write down how your day went, successes, lessons, and thoughts before bed.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _journalController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Today went really well. I completed my deep work session and walked 3,000 steps...',
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
          const SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bookmark_added_outlined, size: 18),
              label: const Text('Save Reflection', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveReflection,
            ),
          ),
          if (pastJournals.isNotEmpty) ...[
            const SizedBox(height: 32.0),
            Text(
              'PAST REFLECTIONS TIMELINE',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pastJournals.length,
              itemBuilder: (context, index) {
                final entry = pastJournals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.03)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () {
                              ref.read(journalProvider.notifier).saveJournal(entry.key, '');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
