// issue_reports_notifier.dart — Submitting and managing issue reports.
//
// Two separate providers rather than one, because the two audiences need
// different queries and different RLS-permitted operations:
//   myReportsProvider    — any user's own submitted reports + submitReport().
//                          Backed by the "user_id = auth.uid()" half of the
//                          issue_reports SELECT policy.
//   adminReportsProvider — every report in the system + updateStatus().
//                          Only returns real rows for an admin (RLS); a
//                          non-admin gets the same empty/own-only result the
//                          SELECT policy would give a direct query, but this
//                          provider is only ever read from admin_screen.dart,
//                          which is itself gated on roleProvider.
//
// Connections:
//   issue_report.dart      — IssueReport model, IssueStatus enum
//   role_provider.dart     — admin_screen.dart gates access to adminReportsProvider
//   auth_provider.dart     — currentUserIdProvider scopes myReportsProvider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_provider.dart';
import 'issue_report.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// My reports — submitter's own view
// ---------------------------------------------------------------------------

class MyReportsNotifier extends AsyncNotifier<List<IssueReport>> {
  @override
  Future<List<IssueReport>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    return _fetchMine(userId);
  }

  Future<List<IssueReport>> _fetchMine(String userId) async {
    final rows = await Supabase.instance.client
        .from('issue_reports')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => IssueReport.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Submits a new issue report from the current user.
  Future<void> submitReport({
    required String title,
    required String description,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final now = DateTime.now().toIso8601String();
    await Supabase.instance.client.from('issue_reports').insert({
      'id': _uuid.v4(),
      'user_id': userId,
      'title': title,
      'description': description,
      'status': 'open',
      'created_at': now,
      'updated_at': now,
    });

    state = AsyncData(await _fetchMine(userId));
  }
}

final myReportsProvider =
    AsyncNotifierProvider<MyReportsNotifier, List<IssueReport>>(
      MyReportsNotifier.new,
    );

// ---------------------------------------------------------------------------
// Admin queue — every report, with reporter names joined in client-side
// ---------------------------------------------------------------------------

class AdminReportsNotifier extends AsyncNotifier<List<IssueReport>> {
  @override
  Future<List<IssueReport>> build() => _fetchAll();

  Future<List<IssueReport>> _fetchAll() async {
    final rows = await Supabase.instance.client
        .from('issue_reports')
        .select()
        .order('created_at', ascending: false);
    final reports = (rows as List)
        .map((r) => IssueReport.fromMap(r as Map<String, dynamic>))
        .toList();
    if (reports.isEmpty) return reports;

    // No FK between issue_reports and profiles, so PostgREST can't
    // auto-embed — fetch the reporters separately and merge client-side
    // (matches this project's existing no-FK convention, see memory).
    final userIds = reports.map((r) => r.userId).toSet().toList();
    final profileRows = await Supabase.instance.client
        .from('profiles')
        .select('id, username, full_name')
        .inFilter('id', userIds);
    final names = <String, String>{
      for (final p in (profileRows as List))
        (p as Map<String, dynamic>)['id'] as String:
            _displayName(p['full_name'] as String?, p['username'] as String?),
    };

    return [
      for (final r in reports) r.copyWith(reporterName: names[r.userId]),
    ];
  }

  String _displayName(String? fullName, String? username) {
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();
    if (username != null && username.trim().isNotEmpty) return username.trim();
    return 'Unknown user';
  }

  /// Updates a report's status and/or admin notes. Setting status to
  /// resolved stamps resolvedAt/By; moving off resolved (reopening) clears
  /// them.
  Future<void> updateReport(
    String reportId, {
    required IssueStatus status,
    String? adminNotes,
  }) async {
    final adminId = Supabase.instance.client.auth.currentUser?.id;
    final now = DateTime.now().toIso8601String();
    final resolved = status == IssueStatus.resolved;

    await Supabase.instance.client
        .from('issue_reports')
        .update({
          'status': status.dbValue,
          'updated_at': now,
          'resolved_at': resolved ? now : null,
          'resolved_by': resolved ? adminId : null,
          if (adminNotes != null) 'admin_notes': adminNotes,
        })
        .eq('id', reportId);

    state = AsyncData(await _fetchAll());
  }
}

final adminReportsProvider =
    AsyncNotifierProvider<AdminReportsNotifier, List<IssueReport>>(
      AdminReportsNotifier.new,
    );
