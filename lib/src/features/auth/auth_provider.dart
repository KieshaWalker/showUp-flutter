// auth_provider.dart — Riverpod providers that expose the logged-in user.
//
// These three providers are the single source of truth for "who is logged in."
// Any widget or notifier that needs to know the current user reads from here
// instead of calling Supabase directly — keeps auth logic in one place.
//
// How it flows:
//   Supabase emits auth events (login, logout, token refresh)
//     → authStateProvider picks them up as a stream
//       → currentUserProvider derives the User object
//         → currentUserIdProvider derives just the UUID string
//
// Connections:
//   main.dart            — _AuthGate watches authStateProvider to decide
//                          whether to show AuthScreen or AppShell
//   profile_notifier.dart — watches currentUserIdProvider to know whose
//                            profile to load / save
//   habits_notifier, nutrition_notifier, pantry_notifier
//                        — read currentUserIdProvider to scope DB queries
//                          to the logged-in user

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Streams every auth event from Supabase (login, logout, token refresh).
// The _AuthGate in main.dart listens to this to route the user in or out.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Derives the current User object from the latest auth event.
// Returns null when no one is logged in.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});

// Derives just the user's UUID string — the most commonly needed piece.
// Returns null when no one is logged in.
// Used as the `userId` key in every database table row.
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});