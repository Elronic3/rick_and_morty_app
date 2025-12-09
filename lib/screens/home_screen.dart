import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rick_morty_app/models/character.dart';
import 'package:rick_morty_app/services/api_service.dart';
import 'package:rick_morty_app/widgets/character_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Character> _characters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadCharacters();
    }
  }

  Future<void> _loadCharacters({bool reset = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _characters.clear();
        _page = 1;
        _hasMore = true;
        _errorMessage = null;
      }
    });

    try {
      final data = await _api.getCharacters(_page, _searchQuery);
      final List results = data['results'];
      final Map info = data['info'] ?? {};

      setState(() {
        _characters.addAll(results.map((e) => Character.fromJson(e)));
        _hasMore = info['next'] != null;
        if (_hasMore) _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // якщо 1 сторінка - помилка, якщо підвантаження - cancelScroll
        if (_page == 1) {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _loadCharacters(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rick & Morty')),
      body: Column(
        children: [
          // пошук
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Пошук на ім\'я...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // контент
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    //  error first load
    if (_errorMessage != null && _characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            ElevatedButton(
              onPressed: () => _loadCharacters(reset: true),
              child: const Text('Повторити'),
            ),
          ],
        ),
      );
    }

    //  empty search
    if (_characters.isEmpty && !_isLoading) {
      return const Center(child: Text('Персонажа не знайдено'));
    }

    // list
    return ListView.builder(
      controller: _scrollController,
      itemCount: _characters.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _characters.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return CharacterCard(character: _characters[index]);
      },
    );
  }
}
