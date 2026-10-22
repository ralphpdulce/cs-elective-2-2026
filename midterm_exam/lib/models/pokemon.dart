class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  factory Pokemon.fromBasicJson(
    Map<String, dynamic> json, {
    List<String> types = const [],
  }) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((part) => part.isNotEmpty).last);

    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      types: types,
    );
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final rawTypes = (json['types'] as List<dynamic>?) ?? [];
    final types = rawTypes.map((t) {
      final typeObj = (t as Map<String, dynamic>)['type'] as Map<String, dynamic>;
      return _capitalize(typeObj['name'] as String);
    }).toList();

    final sprites = json['sprites'] as Map<String, dynamic>?;
    final frontDefault = sprites?['front_default'] as String?;
    final imageUrl = frontDefault ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      imageUrl: imageUrl,
      types: types,
    );
  }

  Pokemon copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? types,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
