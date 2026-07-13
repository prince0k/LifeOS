import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database/database_service.dart';

/// Provider for accessing the initialized [DatabaseService] instance.
/// Overridden in the [ProviderScope] on app startup to inject the active instance.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('databaseServiceProvider has not been initialized. Overwrite in ProviderScope.');
});
