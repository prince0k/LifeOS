import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/database_provider.dart';

class JournalNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;

  JournalNotifier(this._ref) : super({}) {
    loadAllJournals();
  }

  void loadAllJournals() {
    final dbService = _ref.read(databaseServiceProvider);
    final Map<String, String> journals = {};
    for (var key in dbService.journalsBox.keys) {
      if (key is String) {
        final val = dbService.journalsBox.get(key);
        if (val != null) {
          journals[key] = val;
        }
      }
    }
    state = journals;
  }

  String getJournalForDate(String date) {
    return state[date] ?? '';
  }

  Future<void> saveJournal(String date, String content) async {
    final dbService = _ref.read(databaseServiceProvider);
    if (content.trim().isEmpty) {
      await dbService.journalsBox.delete(date);
      final updated = Map<String, String>.from(state)..remove(date);
      state = updated;
    } else {
      await dbService.journalsBox.put(date, content);
      final updated = Map<String, String>.from(state)..[date] = content;
      state = updated;
    }
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, Map<String, String>>((ref) {
  return JournalNotifier(ref);
});
