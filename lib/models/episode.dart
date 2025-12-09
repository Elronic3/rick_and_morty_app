class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episodeCode;
  final List<String> characterUrls;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
    required this.characterUrls,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'],
      airDate: json['air_date'],
      episodeCode: json['episode'],
      characterUrls: List<String>.from(json['characters'] ?? []),
    );
  }
}
