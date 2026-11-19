/// Model data satu resep. Dipakai untuk data dari API maupun
/// data yang disimpan di penyimpanan lokal (SharedPreferences).
class Recipe {
  final int id;
  final String name;
  final String image;
  final String cuisine;
  final String difficulty;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int caloriesPerServing;
  final double rating;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.caloriesPerServing,
    required this.rating,
    required this.ingredients,
    required this.instructions,
    required this.tags,
  });

  /// Total waktu memasak (persiapan + memasak) dalam menit.
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  /// Mengubah JSON (dari API atau dari SharedPreferences) menjadi objek Recipe.
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      name: (json['name'] ?? '-') as String,
      image: (json['image'] ?? '') as String,
      cuisine: (json['cuisine'] ?? '-') as String,
      difficulty: (json['difficulty'] ?? '-') as String,
      prepTimeMinutes: (json['prepTimeMinutes'] ?? 0) as int,
      cookTimeMinutes: (json['cookTimeMinutes'] ?? 0) as int,
      servings: (json['servings'] ?? 0) as int,
      caloriesPerServing: (json['caloriesPerServing'] ?? 0) as int,
      rating: (json['rating'] ?? 0).toDouble(),
      ingredients: _toStringList(json['ingredients']),
      instructions: _toStringList(json['instructions']),
      tags: _toStringList(json['tags']),
    );
  }

  /// Mengubah objek Recipe menjadi JSON agar bisa disimpan secara lokal.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'cuisine': cuisine,
        'difficulty': difficulty,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'caloriesPerServing': caloriesPerServing,
        'rating': rating,
        'ingredients': ingredients,
        'instructions': instructions,
        'tags': tags,
      };

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
