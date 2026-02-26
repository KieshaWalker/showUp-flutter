import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class UserProfile {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) => UserProfile(
    id: id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as String,
    username: map['username'] as String?,
    fullName: map['full_name'] as String?,
    avatarUrl: map['avatar_url'] as String?,
  );

  /// Display name: prefers fullName, falls back to username, then empty string.
  String get displayName => fullName?.trim().isNotEmpty == true
      ? fullName!.trim()
      : username?.trim().isNotEmpty == true
      ? username!.trim()
      : '';
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;
    return _fetch(userId);
  }

  Future<UserProfile?> _fetch(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (res == null) return UserProfile(id: userId);
      return UserProfile.fromMap(res);
    } on PostgrestException {
      // Table may not exist yet — return an empty profile rather than crashing.
      return UserProfile(id: userId);
    }
  }

  /// Persist full name and/or username to Supabase.
  Future<void> save({String? fullName, String? username}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        if (fullName != null) 'full_name': fullName,
        if (username != null) 'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException {
      rethrow; // surface to UI so the save button can show an error
    }

    state = AsyncData(
      (state.value ?? UserProfile(id: userId)).copyWith(
        fullName: fullName,
        username: username,
      ),
    );
  }

  /// Pick an avatar, upload to Supabase Storage, and persist the public URL.
  Future<void> uploadAvatar(XFile file) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final path = '$userId/avatar.$ext';

    await Supabase.instance.client.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
    );

    // Append a cache-busting timestamp so the image reloads immediately.
    final baseUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);
    final avatarUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });

    state = AsyncData(
      (state.value ?? UserProfile(id: userId)).copyWith(avatarUrl: avatarUrl),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
