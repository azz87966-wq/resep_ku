import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/favorite_service.dart';

/// Halaman 2: Detail resep. Menampilkan bahan dan langkah memasak dari API,
/// serta dua fitur penyimpanan lokal: tombol favorit dan catatan pribadi.
class DetailPage extends StatefulWidget {
  final Recipe recipe;

  const DetailPage({super.key, required this.recipe});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _noteController = TextEditingController();

  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Membaca status favorit dan catatan dari SharedPreferences.
  Future<void> _loadLocalData() async {
    final isFavorite = await _favoriteService.isFavorite(widget.recipe.id);
    final note = await _favoriteService.getNote(widget.recipe.id);

    if (!mounted) return;
    setState(() {
      _isFavorite = isFavorite;
      _noteController.text = note;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite =
        await _favoriteService.toggleFavorite(widget.recipe);

    if (!mounted) return;
    setState(() => _isFavorite = isNowFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          isNowFavorite
              ? 'Resep disimpan ke favorit.'
              : 'Resep dihapus dari favorit.',
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    await _favoriteService.saveNote(widget.recipe.id, _noteController.text);

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Catatan tersimpan di perangkat.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _toggleFavorite,
            tooltip: _isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red.shade300 : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              recipe.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.restaurant_menu, size: 48),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.public,
                      label: recipe.cuisine,
                    ),
                    _InfoChip(
                      icon: Icons.schedule,
                      label: '${recipe.totalTimeMinutes} menit',
                    ),
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${recipe.servings} porsi',
                    ),
                    _InfoChip(
                      icon: Icons.bar_chart,
                      label: recipe.difficulty,
                    ),
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: recipe.rating.toStringAsFixed(1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Bahan-bahan'),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 8),
                          child: Icon(Icons.circle, size: 7),
                        ),
                        Expanded(
                          child: Text(item, style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle('Langkah Memasak'),
                const SizedBox(height: 8),
                ...List.generate(recipe.instructions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            recipe.instructions[index],
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                _SectionTitle('Catatan Pribadi (Tersimpan Lokal)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: kurangi gula, tambah cabai.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveNote,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Catatan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
