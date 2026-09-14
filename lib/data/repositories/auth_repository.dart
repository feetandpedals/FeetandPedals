import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/token_storage.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';

enum SocialProvider { google, apple, facebook }

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> signUp({required String fullName, required String email, required String password});
  Future<AppUser> socialLogin({required SocialProvider provider, required String idToken, String? email, String? fullName});
  Future<void> requestPasswordReset({required String email});
  Future<AppUser?> currentUser();
  Future<AppUser> updateProfile(AppUser user);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  AppUser? _user;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (password.length < 4) {
      throw const ApiException('Incorrect email or password.');
    }
    _user = AppUser(id: 'user-1', fullName: 'Alex Tan', email: email);
    await TokenStorage.instance.saveToken('mock-token-${_user!.id}');
    return _user!;
  }

  @override
  Future<AppUser> signUp({required String fullName, required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = AppUser(id: 'user-1', fullName: fullName, email: email);
    await TokenStorage.instance.saveToken('mock-token-${_user!.id}');
    return _user!;
  }

  @override
  Future<AppUser> socialLogin({
    required SocialProvider provider,
    required String idToken,
    String? email,
    String? fullName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = AppUser(
      id: 'user-1',
      fullName: fullName ?? 'Alex Tan',
      email: email ?? 'alex.tan@example.com',
    );
    await TokenStorage.instance.saveToken('mock-token-${_user!.id}');
    return _user!;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<AppUser?> currentUser() async {
    final token = await TokenStorage.instance.readToken();
    if (token == null) return null;
    return _user ??= const AppUser(id: 'user-1', fullName: 'Alex Tan', email: 'alex.tan@example.com');
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _user = null;
    await TokenStorage.instance.clear();
  }
}

/// Talks to the existing Laravel/Eventiq REST API (see
/// `Feet_and_Pedals_MVP1_Mobile_App_Technology_and_Scope.md`, sections 2 & 5).
/// Endpoint paths mirror the Eventiq reference app's `AppStrings` exactly;
/// `/social-login` is new and needs to be confirmed/built by the backend
/// team per the doc's API audit (classify as "missing and needs to be
/// built" until confirmed).
class ApiAuthRepository implements AuthRepository {
  final ApiClient _client = ApiClient.instance;

  Future<AppUser> _authRequest(String path, Map<String, dynamic> data) {
    return _client.request(
      (dio) => dio.post(path, data: data),
      parse: (data) async {
        final response = ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        );
        final payload = response.data ?? const {};
        final token = (payload['access_token'] ?? payload['token'] ?? '').toString();
        final tokenType = (payload['token_type'] ?? 'Bearer').toString();
        if (token.isNotEmpty) {
          await TokenStorage.instance.saveToken('$tokenType $token'.trim());
        }
        final userJson = payload['user'] as Map<String, dynamic>? ?? payload;
        return AppUser.fromJson(userJson);
      },
    );
  }

  @override
  Future<AppUser> login({required String email, required String password}) {
    return _authRequest(ApiEndpoints.login, {'email': email, 'password': password, 'role': 'user'});
  }

  @override
  Future<AppUser> signUp({required String fullName, required String email, required String password}) {
    return _authRequest(ApiEndpoints.register, {
      'full_name': fullName,
      'register_type': 'email',
      'username': email.split('@').first,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
  }

  @override
  Future<AppUser> socialLogin({
    required SocialProvider provider,
    required String idToken,
    String? email,
    String? fullName,
  }) {
    return _authRequest(ApiEndpoints.socialLogin, {
      'provider': provider.name,
      'id_token': idToken,
      if (email != null) 'email': email,
      if (fullName != null) 'full_name': fullName,
    });
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return _client.request((dio) => dio.post(ApiEndpoints.forgotPassword, data: {'email': email}), parse: (_) {});
  }

  @override
  Future<AppUser?> currentUser() async {
    final token = await TokenStorage.instance.readToken();
    if (token == null) return null;
    try {
      return await _client.request(
        (dio) => dio.get(ApiEndpoints.me),
        parse: (data) => AppUser.fromJson(
          (ApiResponse<Map<String, dynamic>>.fromJson(
            data as Map<String, dynamic>,
            (p0) => p0 as Map<String, dynamic>,
          ).data) ??
              const {},
        ),
      );
    } on ApiException {
      return null;
    }
  }

  @override
  Future<AppUser> updateProfile(AppUser user) {
    return _client.request(
      (dio) => dio.post(ApiEndpoints.updateProfile, data: user.toJson()),
      parse: (data) => AppUser.fromJson(
        (ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        ).data) ??
            const {},
      ),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _client.request((dio) => dio.post(ApiEndpoints.logout), parse: (_) {});
    } catch (_) {
      // Best-effort server-side invalidation; always clear locally.
    }
    await TokenStorage.instance.clear();
  }
}

AuthRepository createAuthRepository() => Env.useMockData ? MockAuthRepository() : ApiAuthRepository();
