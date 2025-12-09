import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rick_morty_app/models/episode.dart';
import 'package:rick_morty_app/models/character.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  // Отримання списку та реалізація пошуку
  Future<Map<String, dynamic>> getCharacters(int page, String? name) async {
    String url = '$_baseUrl/character/?page=$page';
    if (name != null && name.isNotEmpty) {
      url += '&name=$name';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'results': [],
          'info': {'next': null},
        };
      } else {
        throw ApiException('Помилка серверу: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('Немає з\'єднання з сервером');
    } catch (e) {
      throw ApiException('Сталася помилка: $e');
    }
  }

  // Метод для завантаження по ID, приймає список, парсить ID та робить запит
  Future<List<dynamic>> _getMultipleByIds(
    List<String> urls,
    String endpoint,
  ) async {
    if (urls.isEmpty) return [];

    try {
      // ID  з URL
      final ids = urls.map((url) => url.split('/').last).join(',');
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint/$ids'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Якщо id - 1, api вертає об'єкт, інакше - список
        return (data is List) ? data : [data];
      } else {
        throw ApiException('Не вдалось завантажити дані');
      }
    } on SocketException {
      throw ApiException('Немає з\'єднання з сервером');
    }
  }

  Future<List<Episode>> getEpisodes(List<String> urls) async {
    final data = await _getMultipleByIds(urls, 'episode');
    return data.map((e) => Episode.fromJson(e)).toList();
  }

  Future<List<Character>> getCharactersByUrl(List<String> urls) async {
    final data = await _getMultipleByIds(urls, 'character');
    return data.map((e) => Character.fromJson(e)).toList();
  }
}
