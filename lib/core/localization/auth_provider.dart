import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_api_service.dart';
import '../auth/auth_storage.dart';
import 'locale_provider.dart';

//─────────────────────────────────────────────────────────────────────────────
// AuthUser — immutable model holding the signed-in user's data
//─────────────────────────────────────────────────────────────────────────────

class AuthUser {
  final String? id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AuthUser({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Returns the user's initials (up to 2 chars) for the avatar placeholder.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Create AuthUser from UserProfile
  factory AuthUser.fromProfile(UserProfile profile) {
    return AuthUser(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      avatar: profile.avatar,
      createdAt: profile.createdAt,
      lastLoginAt: profile.lastLoginAt,
    );
  }

  /// Create copy with updated fields
  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthState — UI + data state
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final AuthUser? currentUser;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.currentUser,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isAuthenticated,
    AuthUser? currentUser,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
    );
  }
}

//─────────────────────────────────────────────────────────────────────────────
// AuthNotifier — handles login / register / logout + backend API integration
//─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final AuthApiService _authApi = AuthApiService();

  AuthNotifier(this._prefs) : super(const AuthState()) {
    _restoreSession();
  }

  /// Restore previously persisted session on app start.
  void _restoreSession() async {
    try {
      final isAuthenticated = await AuthStorage.isAuthenticated();
      if (isAuthenticated) {
        // Try to get user profile from backend
        try {
          final profile = await _authApi.getProfile();
          final user = AuthUser.fromProfile(profile);
          state = AuthState(
            isAuthenticated: true,
            currentUser: user,
          );
        } catch (e) {
          // If backend fails, clear local auth state
          await AuthStorage.clearAll();
          state = const AuthState();
        }
      }
    } catch (e) {
      // Ignore errors during startup
      state = const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authResponse = await _authApi.login(email, password);
      final user = AuthUser.fromProfile(authResponse.user);

      state = AuthState(
        isAuthenticated: true,
        currentUser: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authResponse = await _authApi.register(name, email, password);
      final user = AuthUser.fromProfile(authResponse.user);

      state = AuthState(
        isAuthenticated: true,
        currentUser: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      state = const AuthState();
    }
  }

  /// Update the currently signed-in user's profile.
  Future<void> updateProfile({required String name, String? email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _authApi.updateProfile(name: name, email: email);
      final updatedUser = AuthUser.fromProfile(profile);
      state = state.copyWith(isLoading: false, currentUser: updatedUser);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // Legacy alias used by old auth_screen.
  Future<void> signUp(String email, String password) =>
      register(email.split('@').first, email, password);
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
