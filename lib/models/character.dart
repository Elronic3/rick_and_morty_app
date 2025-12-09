class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String image;
  final String type;
  final String locationName;
  final List<String> episodeUrls;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.type,
    required this.locationName,
    required this.episodeUrls,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      image: json['image'],
      type: json['type'] ?? '',
      // Безпечне отримання локації
      locationName: json['location'] != null
          ? json['location']['name']
          : 'Unknown',
      episodeUrls: List<String>.from(json['episode'] ?? []),
    );
  }
}
