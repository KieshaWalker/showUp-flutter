// supabase_client.dart — Single shared Supabase client for the entire app.
//
// Supabase is the backend: it handles auth (login/signup), the remote
// database (Postgres), and file storage (avatars).
//
// main.dart calls Supabase.initialize() once at startup using the URL and
// anon key from env.dart. After that, every file that needs to talk to
// Supabase just imports this `supabase` variable and uses it directly —
// no need to pass the client around or look it up again.
//
// Examples of usage across the app:
//   supabase.auth.signInWithPassword(...)   ← auth_screen.dart
//   supabase.from('habits').select()        ← habits_notifier.dart
//   supabase.storage.from('avatars')...     ← profile_notifier.dart

import 'package:supabase_flutter/supabase_flutter.dart';

// Global accessor — use anywhere after Supabase.initialize() in main.dart
final supabase = Supabase.instance.client;