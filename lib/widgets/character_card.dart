import 'package:flutter/material.dart';
import 'package:rick_morty_app/models/character.dart';
import 'package:rick_morty_app/screens/character_detail_screen.dart';

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // detailscreen nav
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CharacterDetailScreen(character: character),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // обробка завантаження  та помилок
              Hero(
                tag: character.id,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(40),
                  child: Image.network(
                    character.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (ctx, error, stackTrace) =>
                        const Icon(Icons.error, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: character.status == 'Alive'
                              ? Colors.green
                              : (character.status == 'Dead'
                                    ? Colors.red
                                    : Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Text('${character.status} - ${character.species}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
