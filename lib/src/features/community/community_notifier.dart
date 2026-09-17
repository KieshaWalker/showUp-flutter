// community_notifier.dart — Every other user's public profile info.
//
// Backed by the same `profiles` table as profile_notifier.dart, just with a
// broader query (everyone except the current user, instead of "my own
// row"). This works because profiles' SELECT policy was widened from
// "own row only" to "any authenticated user" specifically to support this
// screen — see project memory (community dashboard, 2026-09-17) — while the
// write policy (own row only) is untouched, so nobody can edit anyone
// else's profile through this.
//
// Connections:
//   profile_notifier.dart — reuses its UserProfile model + fromMap
//   auth_provider.dart    — currentUserIdProvider, to exclude yourself
//   community_screen.dart — the browsable list + search

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';
import '../profile/profile_notifier.dart';

class CommunityNotifier extends AsyncNotifier<List<UserProfile>> {
  @override
  Future<List<UserProfile>> build() async {
    final userId = ref.watch(currentUserIdProvider);

    final rows = await Supabase.instance.client
        .from('profiles')
        .select()
        .order('full_name', ascending: true);

    return (rows as List)
        .map((r) => UserProfile.fromMap(r as Map<String, dynamic>))
        .where((p) => p.id != userId)
        .toList();
  }
}

final communityProvider =
    AsyncNotifierProvider<CommunityNotifier, List<UserProfile>>(
      CommunityNotifier.new,
    );
