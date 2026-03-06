// database_provider.dart — Riverpod provider that owns the local SQLite database.
//
// AppDatabase (defined in db.dart) is the Drift-powered local database that
// stores everything offline-first: habits, meals, food entries, water logs,
// nutrition goals, pantry foods, and agent memories.
//
// Why a provider? Riverpod manages the lifetime of the database — it creates
// one instance when first accessed and calls db.close() when the app shuts
// down, preventing resource leaks.
//
// Every notifier that reads/writes local data watches this provider:
//   ref.watch(databaseProvider) → gives back the AppDatabase instance
//
// Connections:
//   db.dart         — defines all tables and the AppDatabase class
//   habits_notifier, nutrition_notifier, pantry_notifier
//               — all read this provider to get a DB handle

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Automatically closes the SQLite connection when the provider is disposed
  ref.onDispose(db.close);
  return db;
});