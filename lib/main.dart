import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/services/database/database_service.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized for database paths query
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database Service
  final dbService = DatabaseService();
  await dbService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('LifeOS Ready'),
        ),
      ),
    );
  }
}
