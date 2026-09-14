import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth token across app restarts, using the platform keychain
/// (iOS Keychain / Android Keystore-backed EncryptedSharedPreferences).
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _tokenKey = 'fp_auth_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
