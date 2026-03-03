import 'package:dio/dio.dart';
import '../network/base_api_service.dart';
import 'auth_storage.dart';

/// API service for authentication endpoints
/// Matches: api_docs_for_frontend.md
class AuthApiService extends BaseApiService {
  /// ── Helper: unwrap the standard {success, data, message} envelope ─────────
  Map<String, dynamic> _unwrap(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) {
      throw ApiException(
          message: 'Empty response from server', statusCode: 500);
    }

    // New API wraps everything in {success, data, message}
    if (body.containsKey('success')) {
      if (body['success'] == true && body['data'] != null) {
        return body['data'] as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: body['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    }

    // Fallback: response is already the data (old format — no wrapper)
    return body;
  }

  /// User login — POST /auth/login
  Future<AuthResponse> login(String email, String password) async {
    final response = await post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = _unwrap(response);
    final authData = AuthResponse.fromMap(data);

    await AuthStorage.saveAccessToken(authData.accessToken);
    if (authData.refreshToken != null) {
      await AuthStorage.saveRefreshToken(authData.refreshToken!);
    }
    await AuthStorage.saveUserId(authData.user.id);
    await AuthStorage.saveEmail(email);

    return authData;
  }

  /// User registration — POST /auth/register
  Future<AuthResponse> register(
      String name, String email, String password) async {
    final response = await post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'fullName': name, // API uses 'fullName' (not 'name')
        'email': email,
        'password': password,
      },
    );

    final data = _unwrap(response);
    final authData = AuthResponse.fromMap(data);

    await AuthStorage.saveAccessToken(authData.accessToken);
    if (authData.refreshToken != null) {
      await AuthStorage.saveRefreshToken(authData.refreshToken!);
    }
    await AuthStorage.saveUserId(authData.user.id);
    await AuthStorage.saveEmail(email);

    return authData;
  }

  /// Refresh access token — POST /auth/refresh
  Future<String> refreshToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) {
      throw ApiException(
          message: 'No refresh token available', statusCode: 401);
    }

    final response = await post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = _unwrap(response);
    final newToken = (data['accessToken'] ?? data['token']) as String?;

    if (newToken == null) {
      throw ApiException(message: 'Failed to refresh token', statusCode: 401);
    }

    await AuthStorage.saveAccessToken(newToken);
    return newToken;
  }

  /// Logout — POST /auth/logout
  Future<void> logout() async {
    try {
      final token = await AuthStorage.getAccessToken();
      if (token != null) {
        await post<void>(
          '/auth/logout',
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {
      // Ignore logout errors — always clear local storage
    } finally {
      await AuthStorage.clearAll();
    }
  }

  /// Get current user profile — GET /auth/me
  Future<UserProfile> getProfile() async {
    final token = await AuthStorage.getAccessToken();
    if (token == null) {
      throw ApiException(message: 'Not authenticated', statusCode: 401);
    }

    final response = await get<Map<String, dynamic>>(
      '/auth/me',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = _unwrap(response);
    return UserProfile.fromMap(data);
  }

  /// Update user profile — PATCH /auth/profile
  Future<UserProfile> updateProfile({
    required String name,
    String? email,
  }) async {
    final token = await AuthStorage.getAccessToken();
    if (token == null) {
      throw ApiException(message: 'Not authenticated', statusCode: 401);
    }

    final body = <String, dynamic>{'fullName': name};
    if (email != null && email.isNotEmpty) body['email'] = email;

    final response = await patch<Map<String, dynamic>>(
      '/auth/profile',
      data: body,
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = _unwrap(response);
    return UserProfile.fromMap(data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthResponse — supports both 'token' and 'accessToken' keys
// ─────────────────────────────────────────────────────────────────────────────
class AuthResponse {
  final String accessToken;
  final String? refreshToken; // nullable — new API may not return one
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    // Support 'token' (new API) OR 'accessToken' (old format)
    final token = (map['token'] ?? map['accessToken'])?.toString() ?? '';

    // refreshToken is optional in new API
    final refresh = (map['refreshToken'])?.toString();

    // User data may be in 'user' or inline in 'data'
    final userMap = map['user'] as Map<String, dynamic>? ?? map;

    return AuthResponse(
      accessToken: token,
      refreshToken: refresh,
      user: UserProfile.fromMap(userMap),
    );
  }

  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toMap(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// UserProfile — supports both 'name' and 'fullName' keys
// ─────────────────────────────────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Returns user initials for avatar placeholder
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Support both 'fullName' (new API) and 'name' (old format)
    final displayName = (map['fullName'] ?? map['name'])?.toString() ?? 'User';

    // createdAt may be absent in new API responses
    DateTime? createdAt;
    if (map['createdAt'] != null) {
      createdAt = DateTime.tryParse(map['createdAt'].toString());
    }

    DateTime? lastLoginAt;
    if (map['lastLoginAt'] != null) {
      lastLoginAt = DateTime.tryParse(map['lastLoginAt'].toString());
    }

    return UserProfile(
      id: map['id']?.toString() ?? '',
      name: displayName,
      email: map['email']?.toString() ?? '',
      avatar: map['avatar']?.toString(),
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': name,
        'email': email,
        'avatar': avatar,
        'createdAt': createdAt?.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
      };
}
