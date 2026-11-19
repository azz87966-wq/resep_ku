import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

/// Kelas pembantu untuk penyimpanan lokal memakai SharedPreferences.
///
/// Ada dua key yang dipakai:
/// - [_favoritesKey] : daftar resep favorit (JSON array).
/// - [_notesKey]     : catatan pribadi per resep (JSON object id -> catatan).
class FavoriteService {
  static const String _favoritesKey = 'favorite_recipes';
  static const String _notesKey = 'recipe_notes';

  /// Membaca semua resep favorit yang tersimpan di perangkat.
  Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengecek apakah sebuah resep sudah ada di daftar favorit.
  Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();
    return favorites.any((recipe) => recipe.id == id);
  }

  /// Menambah resep ke favorit kalau belum ada, atau menghapusnya kalau sudah
  /// ada. Mengembalikan status favorit yang baru.
  Future<bool> toggleFavorite(Recipe recipe) async {
    final favorites = await getFavorites();
    final exists = favorites.any((item) => item.id == recipe.id);

    if (exists) {
      favorites.removeWhere((item) => item.id == recipe.id);
    } else {
      favorites.add(recipe);
    }

    await _saveFavorites(favorites);
    return !exists;
  }

  /// Menghapus satu resep dari daftar favorit.
  Future<void> removeFavorite(int id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.id == id);
    await _saveFavorites(favorites);
  }

  /// Membaca catatan pribadi sebuah resep (kosong kalau belum ada catatan).
  Future<String> getNote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return '';

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return (map['$id'] ?? '') as String;
  }

  /// Menyimpan catatan pribadi sebuah resep ke penyimpanan lokal.
  Future<void> saveNote(int id, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    final map = (raw == null || raw.isEmpty)
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;

    if (note.trim().isEmpty) {
      map.remove('$id');
    } else {
      map['$id'] = note.trim();
    }

    await prefs.setString(_notesKey, jsonEncode(map));
  }

  Future<void> _saveFavorites(List<Recipe> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final data = favorites.map((recipe) => recipe.toJson()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(data));
  }
}
