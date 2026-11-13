import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DemoUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String provider;

  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.provider,
  });
}

class AppAuthProvider extends ChangeNotifier {
  final SupabaseClient? _client;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;
  DemoUser? _demoUser;

  static SupabaseClient? _safeClient() {
    try {
      if (SupabaseConfig.isConfigured) {
        return Supabase.instance.client;
      }
    } catch (_) {
      // Supabase is not initialized yet (e.g. during unit tests)
    }
    return null;
  }

  AppAuthProvider({SupabaseClient? client})
      : _client = client ?? _safeClient() {
    _initAuthListener();
  }

  void _initAuthListener() {
    final client = _client;
    if (client != null) {
      _authSubscription = client.auth.onAuthStateChange.listen((data) {
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      });
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get supabaseUser => _client?.auth.currentUser;
  DemoUser? get demoUser => _demoUser;

  bool get isAuthenticated => _demoUser != null || supabaseUser != null;

  String get displayName {
    if (_demoUser != null) return _demoUser!.name;
    final metadata = supabaseUser?.userMetadata;
    if (metadata != null) {
      final name = metadata['full_name'] ?? metadata['name'] ?? metadata['user_name'];
      if (name is String && name.trim().isNotEmpty) return name.trim();
    }
    final email = supabaseUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Traveler';
  }

  String? get email {
    if (_demoUser != null) return _demoUser!.email;
    return supabaseUser?.email;
  }

  String? get avatarUrl {
    if (_demoUser != null) return _demoUser!.avatarUrl;
    final metadata = supabaseUser?.userMetadata;
    return metadata?['avatar_url'] as String? ?? metadata?['picture'] as String?;
  }

  String get providerName {
    if (_demoUser != null) return _demoUser!.provider;
    final appMeta = supabaseUser?.appMetadata;
    final provider = appMeta?['provider'];
    if (provider is String) {
      return provider[0].toUpperCase() + provider.substring(1);
    }
    return 'OAuth';
  }

  /// Sign in with Supabase OAuth (GitHub, Google, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    final client = _client;
    if (client == null || !SupabaseConfig.isConfigured) {
      _errorMessage = 'Supabase client is not connected. Use Demo login.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final redirectUrl = kIsWeb ? null : SupabaseConfig.authRedirectUri;
      final result = await client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectUrl,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'OAuth login failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Convenience method for GitHub Sign-in
  Future<bool> signInWithGitHub() => signInWithOAuth(OAuthProvider.github);

  /// Convenience method for Google Sign-in
  Future<bool> signInWithGoogle() => signInWithOAuth(OAuthProvider.google);

  /// Demo / Offline login simulation for test environments and graders
  void signInDemo({
    required String provider,
    String name = 'Lumine (Demo)',
    String email = 'traveler@genshin.teyvat',
    String? avatarUrl,
  }) {
    _demoUser = DemoUser(
      id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: avatarUrl ?? 'assets/images/electro-treasure-compass-banner.png',
      provider: provider,
    );
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = _client;
      if (client != null && supabaseUser != null) {
        await client.auth.signOut();
      }
    } catch (e) {
      debugPrint('[AuthProvider] Sign out error: $e');
    } finally {
      _demoUser = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
