import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/profile.dart';
import '../services/supabase_service.dart';
import 'supabase_provider.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final Profile? profile;
  final supa.User? supabaseUser;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
    this.supabaseUser,
  });

  bool get isAuthenticated => profile != null || supabaseUser != null;
  bool get isAdmin => profile?.isAdmin ?? false;
  bool get isCustomer => !isAdmin;

  String get displayName {
    if (profile != null && profile!.fullName.isNotEmpty) {
      return profile!.fullName;
    }
    final meta = supabaseUser?.userMetadata;
    if (meta != null) {
      final name = meta['full_name'] ?? meta['name'] ?? meta['user_name'];
      if (name is String && name.trim().isNotEmpty) return name.trim();
    }
    final mail = profile?.email ?? supabaseUser?.email;
    if (mail != null && mail.contains('@')) {
      return mail.split('@').first;
    }
    return 'Traveler';
  }

  String get email => profile?.email ?? supabaseUser?.email ?? '';

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    Profile? profile,
    supa.User? supabaseUser,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: clearProfile ? null : (profile ?? this.profile),
      supabaseUser: clearProfile ? null : (supabaseUser ?? this.supabaseUser),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _service;
  StreamSubscription<supa.AuthState>? _sub;

  AuthNotifier(this._service) : super(const AuthState()) {
    _initListener();
  }

  void _initListener() {
    final stream = _service.authStateChanges;
    if (stream != null) {
      _sub = stream.listen((event) async {
        final session = event.session;
        if (session != null) {
          final profile = await _service.getProfile(session.user.id);
          final meta = session.user.userMetadata ?? {};
          final fullName = (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
          final parts = fullName.isNotEmpty ? fullName.split(' ') : <String>[];
          final first = (meta['firstname'] ?? (parts.isNotEmpty ? parts.first : '')).toString();
          final last = (meta['lastname'] ?? (parts.length > 1 ? parts.sublist(1).join(' ') : '')).toString();

          state = state.copyWith(
            isLoading: false,
            clearError: true,
            supabaseUser: session.user,
            profile: profile ??
                Profile(
                  id: session.user.id,
                  email: session.user.email ?? '',
                  firstname: first.isNotEmpty ? first : (session.user.email?.split('@').first ?? 'Traveler'),
                  lastname: last,
                  roleId: 1,
                  roleName: 'customer',
                ),
          );
        } else {
          state = const AuthState();
        }
      }, onError: (err) {
        state = state.copyWith(isLoading: false, errorMessage: err.toString());
      });
    }
  }

  /// Sign Up with Email, Password, Firstname, and Lastname
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.signUp(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );

      final user = res?.user ?? _service.currentUser;
      if (user == null && !_service.forceLocal) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign up failed. Please check your information and try again.',
        );
        return false;
      }

      // If Supabase project has email confirmation enabled, inform the user
      if (res != null && res.session == null && !_service.forceLocal) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Account created! Please check your email inbox to verify your account before logging in.',
        );
        return false;
      }

      Profile? profile;
      if (user != null) {
        profile = await _service.getProfile(user.id);
      }
      profile ??= Profile(
        id: user?.id ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstname: firstname,
        lastname: lastname,
        roleId: 1,
        roleName: 'customer',
      );

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        supabaseUser: user,
        profile: profile,
      );
      return true;
    } on supa.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Sign In with Email and Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.signInWithEmail(email: email, password: password);
      final user = res?.user ?? _service.currentUser;

      if (user == null && !_service.forceLocal) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid login credentials. Please check your email and password.',
        );
        return false;
      }

      Profile? profile;
      if (user != null) {
        profile = await _service.getProfile(user.id);
      }
      profile ??= Profile(
        id: user?.id ?? 'user-1',
        email: email,
        firstname: email.split('@').first,
        lastname: '',
        roleId: email.contains('admin') ? 2 : 1,
        roleName: email.contains('admin') ? 'admin' : 'customer',
      );

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        supabaseUser: user,
        profile: profile,
      );
      return true;
    } on supa.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Sign In with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await _service.signInWithGoogle();
      if (!success) {
        state = state.copyWith(isLoading: false, errorMessage: 'Google sign-in was canceled.');
        return false;
      }
      // Listener will pick up session; in live mode, reset loading so UI is responsive
      if (_service.isConnected) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
          profile: const Profile(
            id: 'google-user-1',
            email: 'traveler@gmail.com',
            firstname: 'Lumine',
            lastname: 'Traveler',
            roleId: 1,
            roleName: 'customer',
          ),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _service.signOut();
    state = const AuthState();
  }

  /// Demo helpers for fast evaluation & automated tests
  void setDemoCustomer({String email = 'traveler@gmail.com', String name = 'Lumine'}) {
    state = AuthState(
      isLoading: false,
      profile: Profile(
        id: 'demo-customer-1',
        email: email,
        firstname: name,
        lastname: 'Traveler',
        roleId: 1,
        roleName: 'customer',
      ),
    );
  }

  void setDemoAdmin({String email = 'admin@paimon.com', String name = 'Jean Gunnhildr'}) {
    state = AuthState(
      isLoading: false,
      profile: Profile(
        id: 'demo-admin-1',
        email: email,
        firstname: name,
        lastname: '(Acting Grand Master)',
        roleId: 2,
        roleName: 'admin',
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AuthNotifier(service);
});
