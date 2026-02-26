import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_theme.dart';
import 'profile_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _fullNameCtrl = TextEditingController(text: profile?.fullName ?? '');
    _usernameCtrl = TextEditingController(text: profile?.username ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(profileProvider.notifier).save(
      fullName: _fullNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim().toLowerCase(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  Future<void> _pickAvatar() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    final file = await ImagePicker().pickImage(
      source: choice,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    await ref.read(profileProvider.notifier).uploadAvatar(file);
    if (mounted) setState(() => _uploadingAvatar = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;
    final initials = _initials(profile);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: AppTextStyles.displayLarge,
      ),
      body: ListView(
        padding: AppPaddings.all,
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _AvatarCircle(
                    avatarUrl: profile?.avatarUrl,
                    initials: initials,
                    uploading: _uploadingAvatar,
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkBase, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Fields ──────────────────────────────────────────────────────
          AppGlass.card(
            padding: AppPaddings.section,
            borderRadius: AppRadius.lgAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Full Name', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _fullNameCtrl,
                  style: AppTextStyles.bodyLarge,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Alex Jordan',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Username', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _usernameCtrl,
                  style: AppTextStyles.bodyLarge,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'e.g. alexjordan',
                    prefixText: '@',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Save ────────────────────────────────────────────────────────
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Profile'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _initials(UserProfile? profile) {
    final name = profile?.fullName?.trim() ?? profile?.username?.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Avatar circle widget (shared / usable from other screens)
// ---------------------------------------------------------------------------

class _AvatarCircle extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final bool uploading;

  const _AvatarCircle({
    required this.avatarUrl,
    required this.initials,
    this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.terracotta.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.5), width: 2),
      ),
      child: ClipOval(
        child: uploading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.terracotta),
              )
            : avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialsText(initials),
              )
            : _InitialsText(initials),
      ),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.terracotta,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small avatar for use in other screens (e.g. Settings header)
// ---------------------------------------------------------------------------

class ProfileAvatar extends ConsumerWidget {
  final double size;
  const ProfileAvatar({super.key, this.size = 44});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final initials = _initials(profile);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.terracotta.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.5), width: 1.5),
      ),
      child: ClipOval(
        child: profile?.avatarUrl != null
            ? Image.network(
                profile!.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialsText(initials),
              )
            : _InitialsText(initials),
      ),
    );
  }

  String _initials(UserProfile? profile) {
    final name = profile?.fullName?.trim() ?? profile?.username?.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
