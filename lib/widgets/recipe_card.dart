import 'package:flutter/material.dart';

import '../models/recipe.dart';

/// Kartu resep yang dipakai di halaman Beranda dan halaman Favorit.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final String note;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.note = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.image,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 92,
                    height: 92,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.restaurant_menu),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.cuisine} - ${recipe.difficulty}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _IconText(
                          icon: Icons.schedule,
                          label: '${recipe.totalTimeMinutes} menit',
                        ),
                        _IconText(
                          icon: Icons.star_rounded,
                          label: recipe.rating.toStringAsFixed(1),
                        ),
                        _IconText(
                          icon: Icons.local_fire_department_outlined,
                          label: '${recipe.caloriesPerServing} kal',
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.sticky_note_2_outlined, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onFavoriteTap != null)
                IconButton(
                  onPressed: onFavoriteTap,
                  tooltip:
                      isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red.shade400 : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconText({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
