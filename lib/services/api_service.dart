import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

/// Kelas pembantu untuk mengambil data resep dari Public REST API
/// https://dummyjson.com/recipes (paket http).
class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil daftar resep. Jika [query] diisi, memakai endpoint pencarian.
  Future<List<Recipe>> fetchRecipes({String query = '', int limit = 30}) async {
    final uri = query.trim().isEmpty
        ? Uri.parse('$_baseUrl/recipes?limit=$limit')
        : Uri.parse('$_baseUrl/recipes/search?q=${Uri.encodeQueryComponent(query.trim())}');

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException('Server membalas dengan kode ${response.statusCode}.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (body['recipes'] as List<dynamic>? ?? const []);
      return list
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal memuat data. Periksa koneksi internet Anda.');
    }
  }

  void dispose() => _client.close();
}

/// Error khusus API agar pesan yang tampil di UI mudah dibaca pengguna.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
