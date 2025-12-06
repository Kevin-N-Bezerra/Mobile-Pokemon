import 'package:flutter/material.dart';
import '../modelos/pokemon.dart';
import '../modelos/evolution.dart';
import '../Servicos/poke_api_service.dart';
import '../Widget/PokemonCard.dart';
import 'credito.dart';

class PokeHomePage extends StatefulWidget {
  const PokeHomePage({super.key});

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  final PokeApiService _apiService = PokeApiService();
  final TextEditingController _searchController = TextEditingController();

  Pokemon? _pokemon;
  List<EvolutionStage> _evolution = [];
  bool _isLoading = false;

  bool _isAbilityLoading = false; 

  Future<void> _fetchRandom() async {
    setState(() => _isLoading = true);
    try {
      final p = await _apiService.fetchRandomPokemon();
      final evo = await _apiService.fetchEvolutionChain(p.name);

      setState(() {
        _pokemon = p;
        _evolution = evo;
      });
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar Pokémon aleatório')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchByName() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final p = await _apiService.fetchPokemon(query);
      final evo = await _apiService.fetchEvolutionChain(p.name);

      setState(() {
        _pokemon = p;
        _evolution = evo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pokémon não encontrado')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectFromEvolution(EvolutionStage stage) async {
    setState(() => _isLoading = true);
    try {
      final p = await _apiService.fetchPokemon(stage.name);
      final evo = await _apiService.fetchEvolutionChain(stage.name);

      setState(() {
        _pokemon = p;
        _evolution = evo;
      });
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar Pokémon da evolução')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAbilityDialog(PokemonAbility ability) async {
    setState(() => _isAbilityLoading = true);

    try {
      final description =
          await _apiService.fetchAbilityDescription(ability.name);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(ability.displayName),
            content: Text(
              description,
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar habilidade')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAbilityLoading = false);
      }
    }
  }

  Widget _buildEvolutionBubble(EvolutionStage stage) {
    final bool isSelected =
        _pokemon != null && stage.id == _pokemon!.id;

    return GestureDetector(
      onTap: () => _selectFromEvolution(stage),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(color: Colors.redAccent, width: 2)
                  : null,
            ),
            child: Image.network(
              stage.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stage.name,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityChips() {
    if (_pokemon == null || _pokemon!.abilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Habilidades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pokemon!.abilities.map((ability) {
            return ActionChip(
              label: Text(ability.displayName),
              onPressed: () => _showAbilityDialog(ability),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Aleatória'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreditsPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome ou número do Pokémon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchByName,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _pokemon == null
                        ? const Text(
                            'Pesquise ou clique em “Aleatório” para ver um Pokémon!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PokemonCard(pokemon: _pokemon!),
                                const SizedBox(height: 16),

                                if (_isAbilityLoading)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  _buildAbilityChips(),

                                const SizedBox(height: 16),

                                const Text(
                                  'Linha de evolução',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _evolution.isNotEmpty
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (int i = 0;
                                                i < _evolution.length;
                                                i++) ...[
                                              _buildEvolutionBubble(
                                                  _evolution[i]),
                                              if (i <
                                                  _evolution.length - 1)
                                                const Padding(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                          horizontal: 8),
                                                  child: Icon(
                                                    Icons.arrow_forward,
                                                    size: 28,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                            ],
                                          ],
                                        ),
                                      )
                                    : const Text(
                                        'Este Pokémon não possui cadeia de evolução cadastrada.',
                                      ),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchRandom,
        label: const Text('Aleatório'),
        icon: const Icon(Icons.catching_pokemon),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
