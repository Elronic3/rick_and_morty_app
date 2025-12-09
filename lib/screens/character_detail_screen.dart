import 'package:flutter/material.dart';
import 'package:rick_morty_app/models/character.dart';
import 'package:rick_morty_app/models/episode.dart';
import 'package:rick_morty_app/services/api_service.dart';
import 'package:rick_morty_app/screens/episode_detail_screen.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late Future<List<Episode>> _episodesFuture;

  @override
  void initState() {
    super.initState();
    // loading  episodes
    _episodesFuture = ApiService().getEpisodes(widget.character.episodeUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.character.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: widget.character.id,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(widget.character.image),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Статус', widget.character.status),
            _buildInfoRow('Вид', widget.character.species),
            _buildInfoRow(
              'Тип',
              widget.character.type.isNotEmpty ? widget.character.type : '-',
            ),
            _buildInfoRow('Остання локація', widget.character.locationName),
            const Divider(height: 30),
            const Text(
              'Епізоди',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Future build for async loading episodes
            FutureBuilder<List<Episode>>(
              future: _episodesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text(
                    'Не вдалося заванажити список епізодів',
                    style: TextStyle(color: Colors.red),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Немає епізодів');
                }

                return Column(
                  children: snapshot.data!
                      .map(
                        (episode) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            episode.episodeCode,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(episode.name),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EpisodeDetailScreen(episode: episode),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
