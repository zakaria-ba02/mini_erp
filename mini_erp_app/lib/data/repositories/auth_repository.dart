import 'package:jwt_decoder/jwt_decoder.dart';

import '../../utils/storage/secure_storage_service.dart';
import '../models/auth_tokens_response.dart';
import '../models/jwt_payload.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  AuthRepository({
    required AuthProvider provider,
    required SecureStorageService storage,
  })  : _provider = provider,
        _storage = storage;

  final AuthProvider _provider;
  final SecureStorageService _storage;

  Future<AuthTokensResponse> login({
    required String username,
    required String password,
  }) async {
    final tokens = await _provider.login(
      LoginRequest(username: username.trim(), password: password),
    );
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<AuthTokensResponse> refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token');
    }
    final tokens = await _provider.refresh(
      RefreshTokenRequest(refreshToken: refreshToken),
    );
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  /// Always clears local tokens, even if the network call fails.
  Future<void> logout() async {
    try {
      await _provider.logout();
    } catch (_) {
      // Ignore network errors — local session must still end.
    } finally {
      await _storage.clearAll();
    }
  }

  Future<void> clearSession() => _storage.clearAll();

  Future<String?> readAccessToken() => _storage.readAccessToken();

  Future<String?> readRefreshToken() => _storage.readRefreshToken();

  JwtPayload? decodeAccessToken(String accessToken) {
    try {
      if (JwtDecoder.isExpired(accessToken)) return null;
      final map = JwtDecoder.decode(accessToken);
      return JwtPayload.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<JwtPayload?> restoreSession() async {
    try {
      final access = await _storage.readAccessToken();
      if (access == null || access.isEmpty) return null;

      final payload = decodeAccessToken(access);
      if (payload != null) return payload;

      // Access expired/invalid — try refresh once.
      final tokens = await refresh();
      return decodeAccessToken(tokens.accessToken);
    } catch (_) {
      try {
        await _storage.clearAll();
      } catch (_) {}
      return null;
    }
  }
}
