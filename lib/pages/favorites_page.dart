import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/favorite_service.dart';
import '../widgets/recipe_card.dart';
import 'detail_page.dart';

/// Halaman 3: Resep Favorit. Seluruh data di halaman ini dibaca dari
/// penyimpanan lokal (SharedPreferences), jadi tetap ada walau aplikasi
/// ditutup dan tanpa koneksi internet.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();

  List<Recipe> _favorites = [];
  Map<int, String> _notes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final favorites = await _favoriteService.getFavorites();
    final notes = <int, String>{};
    for (final recipe in favorites) {
      notes[recipe.id] = await _favoriteService.getNote(recipe.id);
    }

    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Recipe recipe) async {
    await _favoriteService.removeFavorite(recipe.id);
    await _loadFavorites();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('${recipe.name} dihapus dari favorit.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Favorit'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada resep favorit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Tekan ikon hati pada resep di halaman Beranda '
                'untuk menyimpannya di perangkat.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.phone_android, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_favorites.length} resep tersimpan di perangkat ini.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final recipe = _favorites[index];
              return RecipeCard(
                recipe: recipe,
                isFavorite: true,
                note: _notes[recipe.id] ?? '',
                onFavoriteTap: () => _removeFavorite(recipe),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(recipe: recipe),
                    ),
                  );
                  _loadFavorites();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
