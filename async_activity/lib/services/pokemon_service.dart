import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint = Uri.parse(
    'https://pokeapi.co/api/v2/pokemon?limit=30',
  );

  final http.Client _client;

  Future<List<Pokemon>> fetchPokemon() async {
    final response = await _client.get(_endpoint);

    if (response.statusCode != 200) {
      throw Exception('Unable to load Pokemon (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((item) => Pokemon.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
