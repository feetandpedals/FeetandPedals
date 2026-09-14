import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Google + Facebook on both platforms; Apple is added on iOS only, per
/// Apple's requirement that it be offered wherever other social logins are
/// (MVP1 scope doc, section 5).
class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onApple;

  const SocialLoginButtons({
    super.key,
    required this.isLoading,
    required this.onGoogle,
    required this.onFacebook,
    required this.onApple,
  });

  bool get _showApple => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: const Color(0xFFEA4335),
          onTap: isLoading ? null : onGoogle,
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Continue with Facebook',
          icon: Icons.facebook_rounded,
          iconColor: const Color(0xFF1877F2),
          onTap: isLoading ? null : onFacebook,
        ),
        if (_showApple) ...[
          const SizedBox(height: 12),
          _SocialButton(
            label: 'Continue with Apple',
            icon: Icons.apple_rounded,
            iconColor: AppColors.ink,
            onTap: isLoading ? null : onApple,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SocialButton({required this.label, required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: iconColor, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.outline),
      ),
    );
  }
}
