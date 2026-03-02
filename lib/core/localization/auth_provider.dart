import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthUser — immutable model holding the signed-in user's data
// ─────────────────────────────────────────────────────────────────────────────

class AuthUser {
  final String name;
  final String email;

  const AuthUser({required this.name, required this.email});

  /// Returns the user's initials (up to 2 chars) for the avatar placeholder.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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

// ─────────────────────────────────────────────────────────────────────────────
// AuthNotifier — handles login / register / logout + SharedPrefs persistence
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  static const _keyIsAuth = 'auth_is_authenticated';
  static const _keyName = 'auth_user_name';
  static const _keyEmail = 'auth_user_email';

  AuthNotifier(this._prefs) : super(const AuthState()) {
    _restoreSession();
  }

  /// Restore previously persisted session on app start.
  void _restoreSession() {
    final isAuth = _prefs.getBool(_keyIsAuth) ?? false;
    if (isAuth) {
      final name = _prefs.getString(_keyName) ?? '';
      final email = _prefs.getString(_keyEmail) ?? '';
      state = AuthState(
        isAuthenticated: true,
        currentUser: AuthUser(name: name, email: email),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Simulate network call — replace with real API when ready.
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock: any non-empty credentials succeed.
    if (email.isNotEmpty && password.length >= 6) {
      final name = email.split('@').first;
      final user = AuthUser(
        name: _capitalise(name),
        email: email,
      );
      await _persistSession(user);
      state = AuthState(isAuthenticated: true, currentUser: user);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid credentials. Please try again.',
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 1500));

    final user = AuthUser(name: name, email: email);
    await _persistSession(user);
    state = AuthState(isAuthenticated: true, currentUser: user);
  }

  Future<void> logout() async {
    await _prefs.remove(_keyIsAuth);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyEmail);
    state = const AuthState();
  }

  // Legacy alias used by old auth_screen.
  Future<void> signUp(String email, String password) =>
      register(email.split('@').first, email, password);

  Future<void> _persistSession(AuthUser user) async {
    await _prefs.setBool(_keyIsAuth, true);
    await _prefs.setString(_keyName, user.name);
    await _prefs.setString(_keyEmail, user.email);
  }

  String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
