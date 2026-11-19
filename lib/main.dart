import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const ResepKuApp());
}

/// Titik masuk aplikasi ResepKu.
///
/// Opsi pengelolaan data: Opsi 3 (gabungan) -- data resep diambil dari
/// Public REST API https://dummyjson.com/recipes memakai paket http, lalu
/// resep favorit dan catatan pribadi disimpan secara lokal memakai
/// SharedPreferences.
class ResepKuApp extends StatelessWidget {
  const ResepKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE0633A)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
