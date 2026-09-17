// issue_report.dart — Model + status enum for user-submitted issue reports.
//
// Reports are remote-only (Supabase `issue_reports` table), same as
// `profiles` — there's no local Drift mirror, since this is inherently
// collaborative data (a user's report needs to reach admins, and an
// admin's status change needs to reach the reporter) rather than
// offline-first personal data.
//
// Connections:
//   issue_reports_notifier.dart — fetches/submits/updates these
//   report_issue_screen.dart    — submission form + "your reports" list
//   admin_screen.dart           — the full queue, status management

enum IssueStatus { open, inProgress, resolved }

extension IssueStatusX on IssueStatus {
  String get dbValue => switch (this) {
    IssueStatus.open => 'open',
    IssueStatus.inProgress => 'in_progress',
    IssueStatus.resolved => 'resolved',
  };

  String get label => switch (this) {
    IssueStatus.open => 'Open',
    IssueStatus.inProgress => 'In Progress',
    IssueStatus.resolved => 'Resolved',
  };

  static IssueStatus fromDb(String value) => switch (value) {
    'in_progress' => IssueStatus.inProgress,
    'resolved' => IssueStatus.resolved,
    _ => IssueStatus.open,
  };
}

class IssueReport {
  final String id;
  final String userId;
  final String title;
  final String description;
  final IssueStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? adminNotes;

  /// Reporter's display name — populated client-side by the admin notifier
  /// (joined against `profiles`, since there's no FK for PostgREST to
  /// auto-embed). Null for a user's own report list, where it's redundant.
  final String? reporterName;

  const IssueReport({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.adminNotes,
    this.reporterName,
  });

  IssueReport copyWith({
    IssueStatus? status,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? adminNotes,
    String? reporterName,
  }) => IssueReport(
    id: id,
    userId: userId,
    title: title,
    description: description,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    resolvedBy: resolvedBy ?? this.resolvedBy,
    adminNotes: adminNotes ?? this.adminNotes,
    reporterName: reporterName ?? this.reporterName,
  );

  factory IssueReport.fromMap(Map<String, dynamic> map) => IssueReport(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    status: IssueStatusX.fromDb(map['status'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    resolvedAt: map['resolved_at'] == null
        ? null
        : DateTime.parse(map['resolved_at'] as String),
    resolvedBy: map['resolved_by'] as String?,
    adminNotes: map['admin_notes'] as String?,
  );
}
