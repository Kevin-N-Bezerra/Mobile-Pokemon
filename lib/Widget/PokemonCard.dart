import 'package:flutter/material.dart';
import '../modelos/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonCard({super.key, required this.pokemon});

  static final Map<String, Map<String, dynamic>> typeInfo = {
    'normal': {'color': Colors.brown, 'icon': Icons.circle},
    'fire': {'color': Colors.redAccent, 'icon': Icons.local_fire_department},
    'water': {'color': Colors.blueAccent, 'icon': Icons.water_drop},
    'electric': {'color': Colors.amber, 'icon': Icons.bolt},
    'grass': {'color': Colors.green, 'icon': Icons.eco},
    'ice': {'color': Colors.cyanAccent, 'icon': Icons.ac_unit},
    'fighting': {'color': Colors.orange, 'icon': Icons.sports_mma},
    'poison': {'color': Colors.purple, 'icon': Icons.coronavirus},
    'ground': {'color': Colors.brown, 'icon': Icons.terrain},
    'flying': {'color': Colors.indigoAccent, 'icon': Icons.air},
    'psychic': {'color': Colors.pinkAccent, 'icon': Icons.auto_awesome},
    'bug': {'color': Colors.lightGreen, 'icon': Icons.bug_report},
    'rock': {'color': Colors.grey, 'icon': Icons.landscape},
    'ghost': {'color': Colors.deepPurple, 'icon': Icons.blur_on},
    'dragon': {'color': Colors.indigo, 'icon': Icons.whatshot},
    'dark': {'color': Colors.black54, 'icon': Icons.dark_mode},
    'steel': {'color': Colors.blueGrey, 'icon': Icons.settings},
    'fairy': {'color': Colors.pinkAccent, 'icon': Icons.auto_fix_high},
  };

  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/pokemon/${pokemon.id}.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  size: 100,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '#${pokemon.id} - ${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: pokemon.types.map((type) {
                  final info = typeInfo[type] ?? {'color': Colors.grey, 'icon': Icons.help};
                  return Chip(
                    avatar: Icon(info['icon'], color: Colors.white, size: 18),
                    label: Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: info['color'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Column(
                children: pokemon.stats.entries.map((entry) {
                  final statName = entry.key;
                  final statValue = entry.value;
                  final normalizedValue = statValue / 255.0;

                  Color color;
                  switch (statName) {
                    case 'hp':
                      color = Colors.redAccent;
                      break;
                    case 'attack':
                      color = Colors.orangeAccent;
                      break;
                    case 'defense':
                      color = const Color.fromARGB(255, 179, 228, 230);
                      break;
                    case 'special-attack':
                      color = Colors.blueAccent;
                      break;
                    case 'special-defense':
                      color = Colors.greenAccent[400]!;
                      break;
                    case 'speed':
                      color = Colors.purpleAccent;
                      break;
                    default:
                      color = Colors.grey;
                  }

                  final statNamesPt = {
                    'hp': 'HP',
                    'attack': 'Ataque',
                    'defense': 'Defesa',
                    'special-attack': 'Atk Esp',
                    'special-defense': 'Def Esp',
                    'speed': 'Velocidade',
                  };
                  final label = statNamesPt[statName] ?? statName;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: normalizedValue.clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, _) {
                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(statValue.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(),
              Text(
                pokemon.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
