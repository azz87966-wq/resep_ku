# ResepKu

Aplikasi katalog resep masakan yang dibuat dengan Flutter untuk UTP Praktikum
Mobile Programming.

- **Nama:** Abdullah
- **NPM:** 065124029
- **Kelas:** A
- **Opsi pengelolaan data:** Opsi 3 (gabungan REST API + penyimpanan lokal)

## Ringkasan

Data resep diambil dari Public REST API [dummyjson.com/recipes](https://dummyjson.com/recipes)
memakai paket `http`. Resep yang disukai beserta catatan pribadi disimpan di
perangkat memakai `shared_preferences`, sehingga tetap tersedia saat aplikasi
dibuka kembali tanpa koneksi internet.

## Tangkapan layar

| Beranda | Pencarian | Detail |
| --- | --- | --- |
| <img src="screenshots/home.jpg" width="230"> | <img src="screenshots/search.jpg" width="230"> | <img src="screenshots/detail.jpg" width="230"> |

| Catatan pribadi | Favorit |
| --- | --- |
| <img src="screenshots/detail_note.jpg" width="230"> | <img src="screenshots/favorites.jpg" width="230"> |

## Tiga halaman

| Halaman | File | Isi |
| --- | --- | --- |
| Beranda | `lib/pages/home_page.dart` | Daftar resep dari API, pencarian, loading, error + tombol coba lagi |
| Detail | `lib/pages/detail_page.dart` | Bahan, langkah memasak, tombol favorit, catatan pribadi |
| Favorit | `lib/pages/favorites_page.dart` | Daftar resep favorit dari penyimpanan lokal |

## Struktur folder

```
lib/
  main.dart                  # Titik masuk aplikasi + tema
  models/recipe.dart         # Model data resep (fromJson / toJson)
  services/api_service.dart  # Pemanggilan REST API dengan http
  services/favorite_service.dart  # Penyimpanan lokal SharedPreferences
  pages/home_page.dart       # Halaman 1
  pages/detail_page.dart     # Halaman 2
  pages/favorites_page.dart  # Halaman 3
  widgets/recipe_card.dart   # Kartu resep yang dipakai ulang
```

## Pustaka (pubspec.yaml)

| Pustaka | Versi | Kegunaan |
| --- | --- | --- |
| `http` | ^1.2.2 | Memanggil REST API |
| `shared_preferences` | ^2.3.3 | Menyimpan favorit dan catatan di perangkat |
| `cupertino_icons` | ^1.0.8 | Set ikon tambahan |

## Cara menjalankan

```bash
flutter pub get
flutter run
```

Untuk menjalankan di browser:

```bash
flutter run -d chrome
```
