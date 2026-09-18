// community_screen.dart — Browse other users' profiles.
//
// Reached from a Community icon in presentation_screen.dart's (Overview)
// AppBar, to the left of the Settings icon — moved there from a "Browse
// Community" row in Settings on 2026-09-18 for a one-tap reach from the
// screen users land on.
//
// A search-filtered 4-column grid, same shape (SliverGridDelegateWithFixed-
// CrossAxisCount, AppSpacing.sm gaps) as pantry_screen.dart's food grid and
// habits_screen.dart's habit grid, for visual consistency with the rest of
// the app.
//
// Connections:
//   community_notifier.dart    — communityProvider (every other user)
//   public_profile_screen.dart — read-only detail, opened on tap
//   profile_notifier.dart      — UserProfile model
//   presentation_screen.dart   — AppBar's Community icon opens this

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../profile/profile_notifier.dart';
import 'community_notifier.dart';
import 'public_profile_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(communityProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Community')),
        body: communityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              "Couldn't load the community list.",
              style: AppTextStyles.bodyMedium,
            ),
          ),
          data: (people) {
            final query = _query.trim().toLowerCase();
            final filtered = query.isEmpty
                ? people
                : people.where((p) {
                    final name = p.displayName.toLowerCase();
                    final username = (p.username ?? '').toLowerCase();
                    return name.contains(query) || username.contains(query);
                  }).toList();

            return Column(
              children: [
                Padding(
                  padding: AppPaddings.all,
                  child: AppGlass.card(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.lgAll,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.textOnDarkTertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search people…',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnDarkTertiary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textOnDarkTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            people.isEmpty
                                ? 'No one else has joined yet.'
                                : 'No matches for "$_query".',
                            style: AppTextStyles.bodyMedium,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.lg,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisExtent: 140,
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) =>
                              _PersonCard(profile: filtered[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Vertical card — same grid-card language as pantry_screen.dart's
// _FoodCard and habits_screen.dart's habit card (icon/identity row up top,
// name + subtitle below), sized to hold up at 4-per-row on a 375px iPhone.
class _PersonCard extends StatelessWidget {
  final UserProfile profile;
  const _PersonCard({required this.profile});

  String get _initials {
    final name = profile.displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName;
    final username = profile.username;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicProfileScreen(profile: profile),
          ),
        ),
        borderRadius: AppRadius.lgAll,
        child: AppGlass.card(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.lgAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.terracotta.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: profile.avatarUrl != null
                          ? Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  _initials,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.terracotta,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _initials,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textOnDarkTertiary,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Unnamed user',
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (username != null && username.isNotEmpty)
                    Text(
                      '@$username',
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
