// auth_screen.dart — Login and sign-up screen shown when no user is logged in.
//
// Shown by: main.dart → _AuthGate when authStateProvider has no session.
// Dismissed automatically: when Supabase fires a successful auth event,
//   authStateProvider updates → _AuthGate rebuilds → AppShell replaces this.
//
// The screen toggles between Login and Sign Up mode via _isLogin.
//
// _submit():
//   Login mode  → calls supabase.auth.signInWithPassword()
//   Sign-up mode → calls supabase.auth.signUp(), then upserts full_name (if
//     given) and terms_accepted_at/terms_version (always — sign-up is
//     gated on the "I agree to the Terms" checkbox, _agreedToTerms) to the
//     profiles table
//   On AuthException (bad credentials, email not confirmed, etc.)
//     → _friendlyAuthError() converts raw Supabase messages to plain English
//   On any other exception (network failure, etc.)
//     → shows a generic "something went wrong" message and prints to console
//
// _friendlyAuthError():
//   Maps Supabase's technical error strings to human-readable messages so
//   users never see things like "invalid_credentials" or status codes.
//
// Connections:
//   supabase_client.dart — Supabase.instance.client used for auth calls
//   main.dart            — _AuthGate shows/hides this screen based on session
//   app_theme.dart       — AppBackground, AppColors, AppTextStyles
//   terms_screen.dart    — full Terms & Agreement text, opened by tapping
//                          the sign-up checkbox's "Terms & Agreement" link
//   terms_content.dart   — kTermsVersion, recorded with terms_accepted_at

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../legal/terms_content.dart' show kTermsVersion;
import '../legal/terms_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  String? _error;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await _supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final response = await _supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final name = _nameController.text.trim();
        final userId = response.user?.id;
        if (userId != null) {
          try {
            await _supabase.from('profiles').upsert({
              'id': userId,
              if (name.isNotEmpty) 'full_name': name,
              // Sign-up is gated on _agreedToTerms (see the checkbox
              // below), so reaching here always means the user accepted.
              'terms_accepted_at': DateTime.now().toIso8601String(),
              'terms_version': kTermsVersion,
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            // Non-fatal: the account was created successfully even if the
            // profile row couldn't be saved right away.
            // ignore: avoid_print
            print('[Auth] failed to save profile: $e');
          }

          final inviteCode = _inviteCodeController.text.trim();
          if (inviteCode.isNotEmpty) {
            // An invalid/already-used code never blocks account creation —
            // it just means the account stays a regular (non-admin) user.
            try {
              final granted = await _supabase.rpc(
                'redeem_admin_invite',
                params: {'invite_code': inviteCode},
              ) as bool;
              if (mounted && !granted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invite code not recognized — account created as a regular user.',
                    ),
                  ),
                );
              }
            } catch (e) {
              // ignore: avoid_print
              print('[Auth] failed to redeem invite code: $e');
            }
          }
        }
      }
    } on AuthException catch (e) {
      setState(() => _error = _friendlyAuthError(e.message));
    } catch (e) {
      // ignore: avoid_print
      print('[Auth] unexpected error: $e');
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') || m.contains('invalid email or password')) {
      return 'Incorrect email or password.';
    }
    if (m.contains('email not confirmed')) {
      return 'Please check your email and confirm your account first.';
    }
    if (m.contains('user already registered') || m.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (m.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    if (m.contains('unable to validate email') || m.contains('invalid format')) {
      return 'Please enter a valid email address.';
    }
    if (m.contains('signup_disabled') || m.contains('signups not allowed')) {
      return 'Sign ups are currently disabled.';
    }
    if (m.contains('for security purposes') || m.contains('after')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (m.contains('network') || m.contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo — sized as a fraction of the available width (instead
              // of a fixed 333×400px) so it scales down on the narrowest
              // iPhones instead of overflowing past the screen edge.
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.55,
                  child: AspectRatio(
                    aspectRatio: 333 / 400,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // this box is for spacing between logo and text, not the top padding

              const SizedBox(height: 48),
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.mail_outline, color: AppColors.khaki),
                ),
              ),
              const SizedBox(height: 14),

              // Name (signup only)
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.khaki),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _inviteCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Admin invite code (optional)',
                    prefixIcon: Icon(Icons.key_outlined, color: AppColors.khaki),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppColors.khaki),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.khaki,
                    ),
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),

              // Terms & Agreement acceptance (signup only) — required to
              // create an account; login doesn't need it since acceptance
              // is already on file from when the account was created.
              if (!_isLogin) ...[
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.terracotta,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium,
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TermsScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Terms & Agreement',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.terracotta,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Error
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.terracotta.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.terracotta),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit
              FilledButton(
                onPressed: (_loading || (!_isLogin && !_agreedToTerms))
                    ? null
                    : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isLogin ? 'Log in' : 'Create account'),
              ),
              const SizedBox(height: 16),

              // Toggle
              TextButton(
                onPressed: () =>
                    setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account?  Sign up"
                      : 'Already have an account?  Log in',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.terracotta),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
