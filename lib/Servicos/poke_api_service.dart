import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../modelos/pokemon.dart';
import '../modelos/evolution.dart';



class PokeApiService {
  final String baseUrl = 'https://pokeapi.co/api/v2/';

  Future<Pokemon> fetchRandomPokemon() async {
    final randomId = Random().nextInt(898) + 1;
    return fetchPokemon(randomId.toString());
  }

  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final url = Uri.parse('${baseUrl}pokemon/$nameOrId');
    final speciesUrl = Uri.parse('${baseUrl}pokemon-species/$nameOrId');

    final responses = await Future.wait([
      http.get(url),
      http.get(speciesUrl),
    ]);

    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      final pokeJson = jsonDecode(responses[0].body);
      final speciesJson = jsonDecode(responses[1].body);

      final entries = speciesJson['flavor_text_entries'] as List;
      String? flavor;

      final ptEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'pt',
        orElse: () => null,
      );
      final enEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => null,
      );

      if (ptEntry != null) {
        flavor = ptEntry['flavor_text'];
      } else if (enEntry != null) {
        flavor = enEntry['flavor_text'];
      } else {
        flavor = 'Descrição não disponível.';
      }

      flavor = flavor!.replaceAll('\n', ' ').replaceAll('\f', ' ');

      return Pokemon.fromJson(pokeJson, flavor);
    } else {
      throw Exception('Pokémon não encontrado.');
    }
  }

  Future<List<EvolutionStage>> fetchEvolutionChain(String nameOrId) async {
    final speciesUrl = Uri.parse('${baseUrl}pokemon-species/$nameOrId');
    final speciesResponse = await http.get(speciesUrl);

    if (speciesResponse.statusCode != 200) {
      throw Exception('Não foi possível carregar a species.');
    }

    final speciesJson = jsonDecode(speciesResponse.body);
    final evoChainUrl = speciesJson['evolution_chain']['url'];

    final evoResponse = await http.get(Uri.parse(evoChainUrl));
    if (evoResponse.statusCode != 200) {
      throw Exception('Não foi possível carregar a cadeia de evolução.');
    }

    final evoJson = jsonDecode(evoResponse.body);

    final List<EvolutionStage> stages = [];
    _parseEvolutionChain(evoJson['chain'], stages);

    return stages;
  }

Future<String> fetchAbilityDescription(String abilityName) async {
  final url = Uri.parse('${baseUrl}ability/$abilityName');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Não foi possível carregar a habilidade.');
  }

  final data = jsonDecode(response.body);

  final entries = data['flavor_text_entries'] as List;
  String? flavor;

  // tenta PT primeiro
  final ptEntry = entries.firstWhere(
    (e) => e['language']['name'] == 'pt',
    orElse: () => null,
  );

  final enEntry = entries.firstWhere(
    (e) => e['language']['name'] == 'en',
    orElse: () => null,
  );

  if (ptEntry != null) {
    flavor = ptEntry['flavor_text'];
  } else if (enEntry != null) {
    flavor = enEntry['flavor_text'];
  } else {
    flavor = 'Descrição não disponível para esta habilidade.';
  }

  flavor = flavor!.replaceAll('\n', ' ').replaceAll('\f', ' ');
  return flavor;
}


  void _parseEvolutionChain(
      Map<String, dynamic> chainNode, List<EvolutionStage> stages) {
    final species = chainNode['species'];
    final name = species['name'] as String;
    final url = species['url'] as String;

    final idString = url.split('/').where((e) => e.isNotEmpty).last;
    final id = int.tryParse(idString) ?? 0;

    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    stages.add(EvolutionStage(
      name: name,
      id: id,
      imageUrl: imageUrl,
    ));

    final evolvesTo = chainNode['evolves_to'] as List;
    if (evolvesTo.isNotEmpty) {
      for (final next in evolvesTo) {
        _parseEvolutionChain(next, stages);
      }
    }
  }
}
