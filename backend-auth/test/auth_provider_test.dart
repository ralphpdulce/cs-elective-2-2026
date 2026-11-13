import 'package:flutter_test/flutter_test.dart';
import 'package:backend_auth/state/auth_provider.dart';

void main() {
  group('AppAuthProvider Tests', () {
    late AppAuthProvider auth;

    setUp(() {
      auth = AppAuthProvider(client: null);
    });

    test('Initial state is unauthenticated', () {
      expect(auth.isAuthenticated, isFalse);
      expect(auth.displayName, equals('Traveler'));
      expect(auth.email, isNull);
      expect(auth.isLoading, isFalse);
    });

    test('Demo GitHub Sign-in authenticates and sets provider', () {
      auth.signInDemo(
        provider: 'GitHub',
        name: 'Aether (Traveler)',
        email: 'aether@github.com',
      );

      expect(auth.isAuthenticated, isTrue);
      expect(auth.displayName, equals('Aether (Traveler)'));
      expect(auth.email, equals('aether@github.com'));
      expect(auth.providerName, equals('GitHub'));
    });

    test('Demo Google Sign-in authenticates and sets provider', () {
      auth.signInDemo(
        provider: 'Google',
        name: 'Lumine (Traveler)',
        email: 'lumine@gmail.com',
      );

      expect(auth.isAuthenticated, isTrue);
      expect(auth.displayName, equals('Lumine (Traveler)'));
      expect(auth.email, equals('lumine@gmail.com'));
      expect(auth.providerName, equals('Google'));
    });

    test('Sign out clears user session', () async {
      auth.signInDemo(
        provider: 'GitHub',
        name: 'Aether',
        email: 'aether@github.com',
      );
      expect(auth.isAuthenticated, isTrue);

      await auth.signOut();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.email, isNull);
    });
  });
}

