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
    id: map['uuid'] as String,
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
          .eq('uuid', userId)
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
        'uuid': userId,
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
    if (userId == null) throw Exception('Not logged in');

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) throw Exception('Selected file is empty');

    // On web, file.path is a blob URL — use mimeType instead.
    final mime = file.mimeType ?? 'image/jpeg';
    final ext = mime.split('/').last.replaceAll('jpeg', 'jpg');
    final path = '$userId/avatar.$ext';

    // ignore: avoid_print
    print('[Avatar] uploading $path (${bytes.length} bytes, $mime)');

    // Step 1: upload binary to storage
    final storageResponse = await Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: mime),
        );

    // ignore: avoid_print
    print('[Avatar] storage response: $storageResponse');

    if (storageResponse.isEmpty) {
      throw Exception('Storage upload returned empty path');
    }

    // Step 2: get URL — try public first, fall back to a 1-year signed URL
    String avatarUrl;
    try {
      final baseUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);
      avatarUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      avatarUrl = await Supabase.instance.client.storage
          .from('avatars')
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    }

    // Step 3: persist URL to profiles table
    await Supabase.instance.client.from('profiles').upsert({
      'uuid': userId,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // ignore: avoid_print
    print('[Avatar] public url: $avatarUrl');

    state = AsyncData(
      (state.value ?? UserProfile(id: userId)).copyWith(avatarUrl: avatarUrl),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
