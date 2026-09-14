import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/social_auth_service.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user.dart';
import 'repository_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.errorMessage, this.isLoading = false});

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({AuthStatus? status, AppUser? user, String? errorMessage, bool? isLoading, bool clearError = false}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  final Ref _ref;
  final _social = SocialAuthService.instance;

  Future<void> _bootstrap() async {
    final user = await _ref.read(authRepositoryProvider).currentUser();
    state = AuthState(status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated, user: user);
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUp({required String fullName, required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).signUp(fullName: fullName, email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Returns true on success, false if the user cancelled or it failed.
  Future<bool> signInWithGoogle() => _socialSignIn(SocialProvider.google, _social.signInWithGoogle);

  Future<bool> signInWithFacebook() => _socialSignIn(SocialProvider.facebook, _social.signInWithFacebook);

  Future<bool> signInWithApple() => _socialSignIn(SocialProvider.apple, _social.signInWithApple);

  Future<bool> _socialSignIn(SocialProvider provider, Future<SocialAuthResult?> Function() signIn) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await signIn();
      if (result == null) {
        // User cancelled the native sign-in sheet — not an error.
        state = state.copyWith(isLoading: false);
        return false;
      }
      final user = await _ref.read(authRepositoryProvider).socialLogin(
            provider: provider,
            idToken: result.idToken,
            email: result.email,
            fullName: result.fullName,
          );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(authRepositoryProvider).requestPasswordReset(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> updateProfile(AppUser user) async {
    final updated = await _ref.read(authRepositoryProvider).updateProfile(user);
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    await _social.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));
