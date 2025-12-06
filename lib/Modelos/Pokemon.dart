class PokemonAbility {
  final String name;
  final String url;

  PokemonAbility({
    required this.name,
    required this.url,
  });

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['ability']['name'] as String,
      url: json['ability']['url'] as String,
    );
  }

  String get displayName {
    return name
        .split('-')
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final Map<String, int> stats;
  final String description;
  final List<PokemonAbility> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.stats,
    required this.description,
    required this.abilities,
  });

  factory Pokemon.fromJson(
      Map<String, dynamic> pokeJson, String description) {
    final abilitiesJson = pokeJson['abilities'] as List;
    final abilities = abilitiesJson
        .map((a) => PokemonAbility.fromJson(a as Map<String, dynamic>))
        .toList();

    return Pokemon(
      id: pokeJson['id'],
      name: pokeJson['name'],
      types: (pokeJson['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      stats: {
        for (var s in pokeJson['stats'])
          s['stat']['name']: s['base_stat'] as int,
      },
      description: description,
      abilities: abilities, 
    );
  }
}
