import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:midterm_exam/models/pokemon.dart';
import 'package:midterm_exam/providers/pokemon_provider.dart';
import 'package:midterm_exam/services/pokemon_service.dart';

void main() {
  group('Riverpod State Management Tests', () {
    test('FavoritesNotifier toggles, adds, and removes favorites properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);

      expect(container.read(favoritesProvider), isEmpty);

      // Add Pikachu (ID 25)
      notifier.addFavorite(25);
      expect(container.read(favoritesProvider), contains(25));
      expect(notifier.isFavorite(25), isTrue);

      // Toggle off Pikachu
      notifier.toggleFavorite(25);
      expect(container.read(favoritesProvider), isNot(contains(25)));
      expect(notifier.isFavorite(25), isFalse);

      // Toggle on Charmander (ID 4)
      notifier.toggleFavorite(4);
      expect(container.read(favoritesProvider), contains(4));

      // Remove Charmander
      notifier.removeFavorite(4);
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('NicknamesNotifier assigns, edits, and removes nicknames properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(nicknamesProvider.notifier);

      expect(container.read(nicknamesProvider), isEmpty);

      // Assign nickname
      notifier.setNickname(25, 'Sparky');
      expect(container.read(nicknamesProvider)[25], equals('Sparky'));
      expect(notifier.getNickname(25), equals('Sparky'));

      // Edit nickname
      notifier.setNickname(25, 'Volt Master');
      expect(container.read(nicknamesProvider)[25], equals('Volt Master'));

      // Remove nickname
      notifier.removeNickname(25);
      expect(container.read(nicknamesProvider).containsKey(25), isFalse);

      // Setting blank removes nickname
      notifier.setNickname(1, 'Bulby');
      expect(container.read(nicknamesProvider)[1], equals('Bulby'));
      notifier.setNickname(1, '   ');
      expect(container.read(nicknamesProvider).containsKey(1), isFalse);
    });

    test('TypeFilterNotifier sets and clears type filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(typeFilterProvider.notifier);

      expect(container.read(typeFilterProvider), isNull);

      notifier.setType('Fire');
      expect(container.read(typeFilterProvider), equals('Fire'));

      notifier.clearFilter();
      expect(container.read(typeFilterProvider), isNull);
    });

    test('filteredPokemonProvider filters by search query and type filter', () {
      final testPokemon = [
        const Pokemon(
          id: 1,
          name: 'Bulbasaur',
          imageUrl: 'https://example.com/1.png',
          types: ['Grass', 'Poison'],
        ),
        const Pokemon(
          id: 4,
          name: 'Charmander',
          imageUrl: 'https://example.com/4.png',
          types: ['Fire'],
        ),
        const Pokemon(
          id: 7,
          name: 'Squirtle',
          imageUrl: 'https://example.com/7.png',
          types: ['Water'],
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          pokemonListProvider.overrideWith(
            (ref) => PokemonListNotifierMock(testPokemon),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Initially all 3 are returned
      expect(container.read(filteredPokemonProvider).length, equals(3));

      // Filter by Fire type
      container.read(typeFilterProvider.notifier).setType('Fire');
      final firePokemon = container.read(filteredPokemonProvider);
      expect(firePokemon.length, equals(1));
      expect(firePokemon.first.name, equals('Charmander'));

      // Clear filter
      container.read(typeFilterProvider.notifier).clearFilter();
      expect(container.read(filteredPokemonProvider).length, equals(3));

      // Search by name
      container.read(searchQueryProvider.notifier).state = 'saur';
      final searchResult = container.read(filteredPokemonProvider);
      expect(searchResult.length, equals(1));
      expect(searchResult.first.name, equals('Bulbasaur'));

      // Search by custom nickname
      container.read(searchQueryProvider.notifier).state = 'ShellShock';
      expect(container.read(filteredPokemonProvider), isEmpty);
      container.read(nicknamesProvider.notifier).setNickname(7, 'ShellShock');
      final nicknameSearchResult = container.read(filteredPokemonProvider);
      expect(nicknameSearchResult.length, equals(1));
      expect(nicknameSearchResult.first.name, equals('Squirtle'));
    });
  });
}

class PokemonListNotifierMock extends PokemonListNotifier {
  PokemonListNotifierMock(List<Pokemon> initial) : super(PokemonServiceDummy()) {
    state = PokemonListState(
      status: PokemonStatus.success,
      pokemon: initial,
    );
  }

  @override
  Future<void> fetchPokemon() async {}
}

class PokemonServiceDummy extends PokemonService {
  @override
  Future<List<Pokemon>> fetchPokemon() async => [];
}
