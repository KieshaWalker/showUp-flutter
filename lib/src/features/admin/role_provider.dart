// role_provider.dart — Whether the logged-in user is an admin, and
// redeeming an admin invite code.
//
// Roles live in a separate `user_roles` table (not a column on `profiles`)
// specifically so a regular user can never self-grant admin: profiles has a
// broad "users can upsert their own row" policy, but user_roles has no
// client-writable policy at all — the only way a row there changes is the
// `redeem_admin_invite` Postgres RPC, which runs as the function-owning
// role (bypassing RLS) and only flips a user to admin when given a real,
// unused invite code. See supabase/functions/ and project memory for the
// full RLS design.
//
// Used from:
//   auth_screen.dart    — optional invite-code field at sign-up
//   settings_screen.dart — "Redeem Admin Invite Code" row (non-admins) and
//                          gating the "Admin" section (admins)
//   admin_screen.dart    — generating new invite codes, managing reports

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';

class RoleNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return false;
    return _fetchIsAdmin(userId);
  }

  Future<bool> _fetchIsAdmin(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();
      return res?['role'] == 'admin';
    } on PostgrestException {
      return false;
    }
  }

  /// Attempts to redeem an admin invite code for the current user.
  /// Returns true if it granted admin, false if the code was invalid,
  /// already used, or expired.
  Future<bool> redeemInviteCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return false;

    final granted = await Supabase.instance.client.rpc(
      'redeem_admin_invite',
      params: {'invite_code': trimmed},
    ) as bool;

    if (granted) state = const AsyncData(true);
    return granted;
  }
}

final roleProvider = AsyncNotifierProvider<RoleNotifier, bool>(
  RoleNotifier.new,
);

// ---------------------------------------------------------------------------
// Invite codes — admin-only generation + listing (admin_screen.dart)
// ---------------------------------------------------------------------------

class InviteCode {
  final String code;
  final DateTime createdAt;
  final String? usedBy;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  const InviteCode({
    required this.code,
    required this.createdAt,
    this.usedBy,
    this.usedAt,
    this.expiresAt,
  });

  bool get isUsed => usedBy != null;

  factory InviteCode.fromMap(Map<String, dynamic> map) => InviteCode(
    code: map['code'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    usedBy: map['used_by'] as String?,
    usedAt: map['used_at'] == null
        ? null
        : DateTime.parse(map['used_at'] as String),
    expiresAt: map['expires_at'] == null
        ? null
        : DateTime.parse(map['expires_at'] as String),
  );
}

class InviteCodesNotifier extends AsyncNotifier<List<InviteCode>> {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
  final _random = Random.secure();

  @override
  Future<List<InviteCode>> build() => _fetch();

  Future<List<InviteCode>> _fetch() async {
    final rows = await Supabase.instance.client
        .from('admin_invite_codes')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => InviteCode.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Generates and stores a new 10-character invite code, returning it.
  Future<String> generate() async {
    final code = List.generate(
      10,
      (_) => _alphabet[_random.nextInt(_alphabet.length)],
    ).join();
    final adminId = Supabase.instance.client.auth.currentUser?.id;

    await Supabase.instance.client.from('admin_invite_codes').insert({
      'code': code,
      'created_by': adminId,
    });

    state = AsyncData(await _fetch());
    return code;
  }
}

final inviteCodesProvider =
    AsyncNotifierProvider<InviteCodesNotifier, List<InviteCode>>(
      InviteCodesNotifier.new,
    );
