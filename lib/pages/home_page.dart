import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../widgets/recipe_card.dart';
import 'detail_page.dart';
import 'favorites_page.dart';

/// Halaman 1: Beranda. Menampilkan daftar resep dari REST API
/// (https://dummyjson.com/recipes) lengkap dengan pencarian,
/// indikator loading, penanganan error, dan hasil kosong.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _searchController = TextEditingController();

  List<Recipe> _recipes = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    // Supaya tombol hapus teks pencarian ikut muncul / hilang.
    _searchController.addListener(() => setState(() {}));
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  /// Mengambil data dari API lalu menyesuaikan state halaman:
  /// loading -> berhasil / error.
  Future<void> _loadRecipes({String query = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _activeQuery = query;
    });

    try {
      final result = await _apiService.fetchRecipes(query: query);
      final favorites = await _favoriteService.getFavorites();

      if (!mounted) return;
      setState(() {
        _recipes = result;
        _favoriteIds = favorites.map((item) => item.id).toSet();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  /// Menyimpan / menghapus resep di penyimpanan lokal.
  Future<void> _toggleFavorite(Recipe recipe) async {
    final isNowFavorite = await _favoriteService.toggleFavorite(recipe);

    if (!mounted) return;
    setState(() {
      if (isNowFavorite) {
        _favoriteIds.add(recipe.id);
      } else {
        _favoriteIds.remove(recipe.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          isNowFavorite
              ? '${recipe.name} disimpan ke favorit.'
              : '${recipe.name} dihapus dari favorit.',
        ),
      ),
    );
  }

  Future<void> _openDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(recipe: recipe)),
    );
    _refreshFavoriteIds();
  }

  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesPage()),
    );
    _refreshFavoriteIds();
  }

  Future<void> _refreshFavoriteIds() async {
    final favorites = await _favoriteService.getFavorites();
    if (!mounted) return;
    setState(() => _favoriteIds = favorites.map((item) => item.id).toSet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepKu'),
        actions: [
          IconButton(
            onPressed: _openFavorites,
            tooltip: 'Resep Favorit',
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _loadRecipes(query: value),
              decoration: InputDecoration(
                hintText: 'Cari resep, misal: pizza',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _loadRecipes();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// Menentukan tampilan isi halaman sesuai keadaan data.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return _MessageView(
        icon: Icons.wifi_off_rounded,
        title: 'Terjadi kesalahan',
        message: _errorMessage,
        actionLabel: 'Coba Lagi',
        onAction: () => _loadRecipes(query: _activeQuery),
      );
    }

    if (_recipes.isEmpty) {
      return _MessageView(
        icon: Icons.search_off_rounded,
        title: 'Resep tidak ditemukan',
        message: 'Coba kata kunci lain.',
        actionLabel: 'Tampilkan Semua',
        onAction: () {
          _searchController.clear();
          _loadRecipes();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadRecipes(query: _activeQuery),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return RecipeCard(
            recipe: recipe,
            isFavorite: _favoriteIds.contains(recipe.id),
            onTap: () => _openDetail(recipe),
            onFavoriteTap: () => _toggleFavorite(recipe),
          );
        },
      ),
    );
  }
}

/// Tampilan pesan serbaguna untuk keadaan error dan hasil kosong.
class _MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
