class Pokemon {
  const Pokemon({required this.id, required this.name, required this.imageUrl});

  final int id;
  final String name;
  final String imageUrl;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((part) => part.isNotEmpty).last);

    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }

  static String _capitalize(String value) =>
      value[0].toUpperCase() + value.substring(1);
}
