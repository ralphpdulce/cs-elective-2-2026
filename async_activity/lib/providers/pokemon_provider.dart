import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus { idle, loading, success, error }

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
    : _service = service ?? PokemonService();

  final PokemonService _service;

  PokemonStatus status = PokemonStatus.idle;
  List<Pokemon> pokemon = const [];
  String? errorMessage;

  Future<void> fetchPokemon() async {
    status = PokemonStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      pokemon = await _service.fetchPokemon();
      status = PokemonStatus.success;
    } catch (error) {
      status = PokemonStatus.error;
      errorMessage = error.toString();
    }

    notifyListeners();
  }
}
