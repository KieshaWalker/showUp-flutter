import 'package:supabase_flutter/supabase_flutter.dart';

// Global accessor — use anywhere after Supabase.initialize() in main.dart
final supabase = Supabase.instance.client;
