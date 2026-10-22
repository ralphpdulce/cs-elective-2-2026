import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus { idle, loading, success, error }

class PokemonListState {
  const PokemonListState({
    this.status = PokemonStatus.idle,
    this.pokemon = const [],
    this.errorMessage,
  });

  final PokemonStatus status;
  final List<Pokemon> pokemon;
  final String? errorMessage;

  PokemonListState copyWith({
    PokemonStatus? status,
    List<Pokemon>? pokemon,
    String? errorMessage,
  }) {
    return PokemonListState(
      status: status ?? this.status,
      pokemon: pokemon ?? this.pokemon,
      errorMessage: errorMessage,
    );
  }
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  PokemonListNotifier(this._service) : super(const PokemonListState()) {
    fetchPokemon();
  }

  final PokemonService _service;

  /// Fetches the Pokémon list from the PokéAPI asynchronously.
  /// Also reused for pull-to-refresh actions.
  Future<void> fetchPokemon() async {
    state = state.copyWith(status: PokemonStatus.loading, errorMessage: null);
    try {
      final result = await _service.fetchPokemon();
      state = state.copyWith(
        status: PokemonStatus.success,
        pokemon: result,
      );
    } catch (error) {
      state = state.copyWith(
        status: PokemonStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}

final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  return PokemonListNotifier(ref.watch(pokemonServiceProvider));
});

/// Nickname State Management
class NicknamesNotifier extends StateNotifier<Map<int, String>> {
  NicknamesNotifier() : super({});

  void setNickname(int pokemonId, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(pokemonId);
    } else {
      state = {...state, pokemonId: trimmed};
    }
  }

  void removeNickname(int pokemonId) {
    if (!state.containsKey(pokemonId)) return;
    final newState = Map<int, String>.from(state);
    newState.remove(pokemonId);
    state = newState;
  }

  String? getNickname(int pokemonId) => state[pokemonId];
}

final nicknamesProvider =
    StateNotifierProvider<NicknamesNotifier, Map<int, String>>((ref) {
  return NicknamesNotifier();
});

/// Favorites State Management
class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({});

  void toggleFavorite(int pokemonId) {
    if (state.contains(pokemonId)) {
      state = Set<int>.from(state)..remove(pokemonId);
    } else {
      state = Set<int>.from(state)..add(pokemonId);
    }
  }

  void addFavorite(int pokemonId) {
    state = Set<int>.from(state)..add(pokemonId);
  }

  void removeFavorite(int pokemonId) {
    state = Set<int>.from(state)..remove(pokemonId);
  }

  bool isFavorite(int pokemonId) => state.contains(pokemonId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

/// Retractable Favorites Panel Visibility
final favoritesPanelExpandedProvider = StateProvider<bool>((ref) => false);

/// Type Filter State Management
class TypeFilterNotifier extends StateNotifier<String?> {
  TypeFilterNotifier() : super(null);

  void setType(String? type) {
    state = type;
  }

  void clearFilter() {
    state = null;
  }
}

final typeFilterProvider =
    StateNotifierProvider<TypeFilterNotifier, String?>((ref) {
  return TypeFilterNotifier();
});

/// Search Query State
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Computed Provider: Available types extracted from fetched Pokémon
final availableTypesProvider = Provider<List<String>>((ref) {
  final listState = ref.watch(pokemonListProvider);
  final typesSet = <String>{};
  for (final pokemon in listState.pokemon) {
    typesSet.addAll(pokemon.types);
  }
  final sorted = typesSet.toList()..sort();
  return sorted;
});

/// Computed Provider: List of favorite Pokémon objects
final favoritePokemonProvider = Provider<List<Pokemon>>((ref) {
  final listState = ref.watch(pokemonListProvider);
  final favoriteIds = ref.watch(favoritesProvider);
  return listState.pokemon
      .where((pokemon) => favoriteIds.contains(pokemon.id))
      .toList();
});

/// Computed Provider: Filtered Pokémon list based on search and type filter
final filteredPokemonProvider = Provider<List<Pokemon>>((ref) {
  final listState = ref.watch(pokemonListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedType = ref.watch(typeFilterProvider);
  final nicknames = ref.watch(nicknamesProvider);

  return listState.pokemon.where((pokemon) {
    final nickname = nicknames[pokemon.id]?.toLowerCase() ?? '';
    final matchesQuery = query.isEmpty ||
        pokemon.name.toLowerCase().contains(query) ||
        nickname.contains(query);

    final matchesType = selectedType == null ||
        pokemon.types
            .any((t) => t.toLowerCase() == selectedType.toLowerCase());

    return matchesQuery && matchesType;
  }).toList();
});
