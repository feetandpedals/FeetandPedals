import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result of a successful social sign-in, handed to [AuthRepository.socialLogin]
/// so the backend can verify the token server-side and mint a Feet and
/// Pedals session.
class SocialAuthResult {
  final String idToken;
  final String? email;
  final String? fullName;

  const SocialAuthResult({required this.idToken, this.email, this.fullName});
}

/// Thin wrapper around the platform social-login SDKs.
///
/// Availability, per the MVP1 scope doc (section 5):
/// - Google Sign-In: Android + iOS.
/// - Facebook Login: Android + iOS.
/// - Sign in with Apple: iOS only (Apple requires it be offered wherever
///   other social logins are offered on iOS; it is not applicable on
///   Android).
///
/// Requires platform setup this repo cannot embed for you (real client
/// IDs/keys are the app owner's to provision):
/// - Android: `android/app/google-services.json` (or a Google OAuth Android
///   client ID) for Google; a Facebook App ID/Client Token in
///   `android/app/src/main/res/values/strings.xml` for Facebook.
/// - iOS: a `GIDClientID` + URL scheme in `ios/Runner/Info.plist` for
///   Google; `FacebookAppID`/`FacebookClientToken`/URL scheme for Facebook;
///   the "Sign in with Apple" capability enabled in the Xcode project.
class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  final GoogleSignIn _google = GoogleSignIn(scopes: const ['email']);

  bool get isAppleAvailable => !kIsWeb && Platform.isIOS;

  /// Returns null if the user cancels the flow.
  Future<SocialAuthResult?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final token = auth.idToken ?? auth.accessToken;
    if (token == null) return null;
    return SocialAuthResult(idToken: token, email: account.email, fullName: account.displayName);
  }

  /// Returns null if the user cancels the flow.
  Future<SocialAuthResult?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(permissions: const ['email', 'public_profile']);
    if (result.status != LoginStatus.success || result.accessToken == null) return null;
    final profile = await FacebookAuth.instance.getUserData(fields: 'name,email');
    return SocialAuthResult(
      idToken: result.accessToken!.tokenString,
      email: profile['email'] as String?,
      fullName: profile['name'] as String?,
    );
  }

  /// Returns null if the user cancels the flow. Only call when
  /// [isAppleAvailable] is true.
  Future<SocialAuthResult?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final fullName = [credential.givenName, credential.familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      return SocialAuthResult(
        idToken: credential.identityToken ?? credential.authorizationCode,
        email: credential.email,
        fullName: fullName.isEmpty ? null : fullName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _google.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }
}
