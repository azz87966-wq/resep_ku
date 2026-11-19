import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resep_ku/models/recipe.dart';

void main() {
  const sample = {
    'id': 1,
    'name': 'Classic Margherita Pizza',
    'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
    'cuisine': 'Italian',
    'difficulty': 'Easy',
    'prepTimeMinutes': 20,
    'cookTimeMinutes': 15,
    'servings': 4,
    'caloriesPerServing': 300,
    'rating': 4.6,
    'ingredients': ['Pizza dough', 'Tomato sauce'],
    'instructions': ['Preheat the oven', 'Bake until golden'],
    'tags': ['Pizza', 'Italian'],
  };

  test('Recipe.fromJson membaca data API dengan benar', () {
    final recipe = Recipe.fromJson(Map<String, dynamic>.from(sample));

    expect(recipe.id, 1);
    expect(recipe.name, 'Classic Margherita Pizza');
    expect(recipe.totalTimeMinutes, 35);
    expect(recipe.ingredients.length, 2);
    expect(recipe.rating, 4.6);
  });

  test('toJson lalu fromJson menghasilkan data yang sama (penyimpanan lokal)',
      () {
    final original = Recipe.fromJson(Map<String, dynamic>.from(sample));
    final restored = Recipe.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored.name, original.name);
    expect(restored.instructions, original.instructions);
    expect(restored.caloriesPerServing, original.caloriesPerServing);
  });

  test('Recipe.fromJson aman ketika sebagian field kosong', () {
    final recipe = Recipe.fromJson({'id': 9});

    expect(recipe.name, '-');
    expect(recipe.ingredients, isEmpty);
    expect(recipe.rating, 0);
  });
}
