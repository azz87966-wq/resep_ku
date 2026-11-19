"""Membangun laporan PDF UTP Praktikum Mobile Programming (aplikasi ResepKu).

Jalankan dari folder proyek:
    pip install reportlab
    python build_report.py
Hasil: Laporan_UTP_ResepKu.pdf
"""

import os

from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    Image,
    KeepTogether,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

# ---------------------------------------------------------------- identitas
NAMA = "Abdullah"
NPM = "065124029"
KELAS = "A"
JUDUL_APP = "ResepKu - Katalog Resep Masakan"
OPSI = "Opsi 3 (Gabungan REST API + Penyimpanan Lokal)"
GITHUB_URL = "https://github.com/azz87966-wq/resep_ku"

OUTPUT = "Laporan_UTP_ResepKu.pdf"
BASE = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(BASE, "screenshots")

ACCENT = colors.HexColor("#C2410C")
INK = colors.HexColor("#1F2937")
MUTED = colors.HexColor("#6B7280")
LINE = colors.HexColor("#E5E7EB")
CODE_BG = colors.HexColor("#F7F7F8")

styles = getSampleStyleSheet()

S_TITLE = ParagraphStyle(
    "TitleX", parent=styles["Title"], fontSize=20, leading=25,
    textColor=INK, spaceAfter=2,
)
S_SUB = ParagraphStyle(
    "SubX", parent=styles["Normal"], fontSize=10.5, leading=14,
    textColor=MUTED, alignment=1, spaceAfter=16,
)
S_H1 = ParagraphStyle(
    "H1X", parent=styles["Heading1"], fontSize=13.5, leading=17,
    textColor=ACCENT, spaceBefore=16, spaceAfter=7,
)
S_H2 = ParagraphStyle(
    "H2X", parent=styles["Heading2"], fontSize=11.5, leading=15,
    textColor=INK, spaceBefore=11, spaceAfter=5,
)
S_BODY = ParagraphStyle(
    "BodyX", parent=styles["BodyText"], fontSize=10.2, leading=15,
    textColor=INK, alignment=TA_JUSTIFY, spaceAfter=7,
)
S_BULLET = ParagraphStyle(
    "BulletX", parent=S_BODY, leftIndent=14, bulletIndent=4, spaceAfter=4,
)
S_CODE = ParagraphStyle(
    "CodeX", parent=styles["Code"], fontSize=7.9, leading=10.4,
    textColor=INK, backColor=CODE_BG, borderPadding=7,
    leftIndent=2, rightIndent=2, spaceBefore=3, spaceAfter=9,
)
S_CAP = ParagraphStyle(
    "CapX", parent=styles["Normal"], fontSize=9, leading=12,
    textColor=MUTED, alignment=1, spaceBefore=4, spaceAfter=12,
)


def para(text, style=S_BODY):
    return Paragraph(text, style)


def bullets(items):
    return [Paragraph(t, S_BULLET, bulletText="•") for t in items]


def code(text):
    safe = (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\n", "<br/>")
        .replace(" ", "&nbsp;")
    )
    return Paragraph(f"<font face='Courier'>{safe}</font>", S_CODE)


def table(rows, widths):
    t = Table(rows, colWidths=widths, hAlign="LEFT")
    t.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 9.2),
                ("TEXTCOLOR", (0, 0), (-1, -1), INK),
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#FDF1EC")),
                ("GRID", (0, 0), (-1, -1), 0.4, LINE),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("LEFTPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    return t


def screenshot(filename, caption, max_h=11.0 * cm):
    """Menyisipkan screenshot kalau filenya ada."""
    path = os.path.join(SHOTS, filename)
    if not os.path.exists(path):
        return [
            para(f"<i>[screenshots/{filename} belum tersedia]</i>", S_CAP)
        ]
    from reportlab.lib.utils import ImageReader

    iw, ih = ImageReader(path).getSize()
    h = max_h
    w = iw * (h / ih)
    max_w = 7.0 * cm
    if w > max_w:
        w = max_w
        h = ih * (w / iw)
    img = Image(path, width=w, height=h)
    img.hAlign = "CENTER"
    return [KeepTogether([img, para(caption, S_CAP)])]


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(2 * cm, A4[1] - 1.5 * cm, A4[0] - 2 * cm, A4[1] - 1.5 * cm)
    canvas.setFont("Helvetica", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(
        2 * cm, A4[1] - 1.35 * cm,
        f"UTP Praktikum Mobile Programming - {NAMA} ({NPM})",
    )
    canvas.drawRightString(
        A4[0] - 2 * cm, 1.2 * cm, f"Halaman {doc.page}"
    )
    canvas.restoreState()


def build():
    doc = SimpleDocTemplate(
        os.path.join(BASE, OUTPUT),
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=2 * cm,
        bottomMargin=1.8 * cm,
        title=f"Laporan UTP Mobile Programming - {NAMA}",
        author=NAMA,
    )

    f = []

    # ------------------------------------------------------------- judul
    f.append(para("LAPORAN UJIAN TENGAH PRAKTIKUM", S_TITLE))
    f.append(para("Praktikum Mobile Programming - Aplikasi ResepKu", S_SUB))

    # ------------------------------------------- 1. identitas & proyek
    f.append(para("1. Identitas dan Informasi Proyek", S_H1))
    f.append(
        table(
            [
                ["Keterangan", "Isi"],
                ["Nama", NAMA],
                ["NPM", NPM],
                ["Kelas", KELAS],
                ["Judul Aplikasi", JUDUL_APP],
                ["Opsi yang Dipilih", OPSI],
                ["Link GitHub (Public)", GITHUB_URL],
            ],
            [5 * cm, 11.5 * cm],
        )
    )

    # ------------------------------------------ 2. deskripsi & fitur
    f.append(para("2. Deskripsi Aplikasi dan Fitur", S_H1))
    f.append(
        para(
            "ResepKu adalah aplikasi katalog resep masakan. Daftar resep "
            "diambil langsung dari Public REST API dummyjson.com/recipes, "
            "lalu pengguna dapat menyimpan resep yang disukai beserta "
            "catatan pribadi ke penyimpanan perangkat. Dengan begitu daftar "
            "favorit tetap bisa dibuka kembali walaupun aplikasi sudah "
            "ditutup dan tanpa koneksi internet. Karena menggabungkan REST "
            "API dengan penyimpanan lokal, aplikasi ini mengambil Opsi 3."
        )
    )
    f.append(para("Fitur utama:", S_H2))
    f.extend(
        bullets(
            [
                "<b>Daftar resep dari API</b> - memuat 30 resep lengkap "
                "dengan gambar, asal masakan, tingkat kesulitan, waktu "
                "memasak, kalori, dan rating.",
                "<b>Pencarian resep</b> - memakai endpoint "
                "<font face='Courier'>/recipes/search?q=</font> pada API.",
                "<b>Detail resep</b> - menampilkan bahan-bahan dan langkah "
                "memasak yang bernomor.",
                "<b>Simpan favorit</b> - satu ketukan pada ikon hati untuk "
                "menyimpan atau menghapus resep di penyimpanan lokal.",
                "<b>Catatan pribadi</b> - pengguna menulis catatan sendiri "
                "pada sebuah resep, disimpan lokal dan tampil juga pada "
                "kartu resep di halaman Favorit.",
                "<b>Penanganan keadaan</b> - indikator loading, tampilan "
                "error dengan tombol Coba Lagi, tampilan hasil pencarian "
                "kosong, tarik untuk menyegarkan, dan gambar pengganti bila "
                "gambar gagal dimuat.",
            ]
        )
    )

    # ---------------------------- 3. pustaka + struktur penyimpanan/API
    f.append(PageBreak())
    f.append(para("3. Pustaka, Struktur API, dan Penyimpanan Lokal", S_H1))
    f.append(para("3.1 Pustaka pada pubspec.yaml", S_H2))
    f.append(
        table(
            [
                ["Pustaka", "Versi", "Kegunaan"],
                ["http", "^1.2.2", "Memanggil Public REST API"],
                [
                    "shared_preferences",
                    "^2.3.3",
                    "Menyimpan favorit dan catatan di perangkat",
                ],
                ["cupertino_icons", "^1.0.8", "Set ikon tambahan"],
                ["flutter_lints", "^5.0.0", "Aturan analisis kode (dev)"],
            ],
            [4.6 * cm, 2.6 * cm, 9.3 * cm],
        )
    )

    f.append(para("3.2 Struktur REST API yang dipakai", S_H2))
    f.append(
        table(
            [
                ["Endpoint", "Kegunaan"],
                [
                    "GET https://dummyjson.com/recipes?limit=30",
                    "Mengambil daftar resep untuk halaman Beranda",
                ],
                [
                    "GET https://dummyjson.com/recipes/search?q=pizza",
                    "Mencari resep sesuai kata kunci",
                ],
            ],
            [8.2 * cm, 8.3 * cm],
        )
    )
    f.append(Spacer(1, 7))
    f.append(
        para(
            "Bentuk balasan API berupa objek JSON dengan kunci "
            "<font face='Courier'>recipes</font> yang berisi array resep. "
            "Field yang dipakai aplikasi:"
        )
    )
    f.append(
        code(
            '{\n'
            '  "recipes": [\n'
            '    {\n'
            '      "id": 1,\n'
            '      "name": "Classic Margherita Pizza",\n'
            '      "ingredients": ["Pizza dough", "Tomato sauce", ...],\n'
            '      "instructions": ["Preheat the oven to 475F", ...],\n'
            '      "prepTimeMinutes": 20,\n'
            '      "cookTimeMinutes": 15,\n'
            '      "servings": 4,\n'
            '      "difficulty": "Easy",\n'
            '      "cuisine": "Italian",\n'
            '      "caloriesPerServing": 300,\n'
            '      "image": "https://cdn.dummyjson.com/recipe-images/1.webp",\n'
            '      "rating": 4.6\n'
            '    }\n'
            '  ],\n'
            '  "total": 50, "skip": 0, "limit": 30\n'
            '}'
        )
    )

    f.append(para("3.3 Struktur penyimpanan lokal (SharedPreferences)", S_H2))
    f.append(
        table(
            [
                ["Key", "Tipe", "Isi"],
                [
                    "favorite_recipes",
                    "String (JSON array)",
                    "Seluruh data resep favorit, hasil Recipe.toJson()",
                ],
                [
                    "recipe_notes",
                    "String (JSON object)",
                    "Catatan pribadi dengan bentuk {id resep: catatan}",
                ],
            ],
            [4.6 * cm, 4.4 * cm, 7.5 * cm],
        )
    )
    f.append(Spacer(1, 7))
    f.append(
        code(
            'favorite_recipes = [\n'
            '  {"id": 1, "name": "Classic Margherita Pizza", "image": "...",\n'
            '   "cuisine": "Italian", "difficulty": "Easy", ... }\n'
            ']\n\n'
            'recipe_notes = {"1": "kurangi keju, tambah oregano"}'
        )
    )

    f.append(para("3.4 Struktur folder proyek", S_H2))
    f.append(
        code(
            "lib/\n"
            "  main.dart                       # titik masuk + tema\n"
            "  models/recipe.dart              # model data (fromJson/toJson)\n"
            "  services/api_service.dart       # pemanggilan REST API (http)\n"
            "  services/favorite_service.dart  # SharedPreferences\n"
            "  pages/home_page.dart            # halaman 1: Beranda\n"
            "  pages/detail_page.dart          # halaman 2: Detail\n"
            "  pages/favorites_page.dart       # halaman 3: Favorit\n"
            "  widgets/recipe_card.dart        # kartu resep (dipakai ulang)"
        )
    )

    # ------------------------------------- 4. alur navigasi + screenshot
    f.append(PageBreak())
    f.append(para("4. Alur Navigasi dan Tangkapan Layar", S_H1))
    f.append(
        para(
            "Aplikasi memiliki tiga halaman yang saling terhubung. Navigasi "
            "memakai <font face='Courier'>Navigator.push</font> dengan "
            "<font face='Courier'>MaterialPageRoute</font>, dan tombol "
            "kembali bawaan AppBar untuk mundur satu halaman. Sesudah "
            "kembali dari halaman Detail atau Favorit, halaman Beranda "
            "membaca ulang data favorit supaya ikon hati selalu sesuai."
        )
    )
    f.append(
        code(
            "Beranda (HomePage)\n"
            "  |-- ketuk kartu resep ------> Detail (DetailPage)\n"
            "  |                              |-- ikon hati: simpan favorit\n"
            "  |                              '-- catatan pribadi: simpan\n"
            "  '-- ikon hati di AppBar ----> Favorit (FavoritesPage)\n"
            "                                 '-- ketuk kartu --> Detail"
        )
    )
    f.extend(
        screenshot(
            "home.jpg",
            "Gambar 1. Halaman Beranda - daftar resep hasil pemanggilan "
            "REST API beserta kolom pencarian.",
        )
    )
    f.extend(
        screenshot(
            "search.jpg",
            "Gambar 2. Pencarian dengan kata kunci \"pizza\" memakai "
            "endpoint /recipes/search pada API.",
        )
    )
    f.extend(
        screenshot(
            "detail.jpg",
            "Gambar 3. Halaman Detail - ikon hati berubah merah dan muncul "
            "pemberitahuan bahwa resep tersimpan ke favorit.",
        )
    )
    f.extend(
        screenshot(
            "detail_note.jpg",
            "Gambar 4. Langkah memasak bernomor dan catatan pribadi yang "
            "sudah tersimpan di penyimpanan lokal.",
        )
    )
    f.extend(
        screenshot(
            "favorites.jpg",
            "Gambar 5. Halaman Favorit - dua resep beserta cuplikan catatan, "
            "seluruhnya dibaca dari SharedPreferences.",
        )
    )

    # ------------------------------------------- 5. penjelasan kode
    f.append(PageBreak())
    f.append(para("5. Penjelasan Kode Utama", S_H1))

    f.append(para("5.1 Pemanggilan REST API (api_service.dart)", S_H2))
    f.append(
        para(
            "Fungsi ini menyusun URL sesuai ada atau tidaknya kata kunci "
            "pencarian, memberi batas waktu 15 detik, memeriksa kode status, "
            "lalu mengubah JSON menjadi daftar objek Recipe. Setiap "
            "kegagalan dibungkus menjadi ApiException agar pesannya mudah "
            "dibaca pengguna."
        )
    )
    f.append(
        code(
            "Future<List<Recipe>> fetchRecipes({String query = '', int limit = 30}) async {\n"
            "  final uri = query.trim().isEmpty\n"
            "      ? Uri.parse('$_baseUrl/recipes?limit=$limit')\n"
            "      : Uri.parse('$_baseUrl/recipes/search?q=...');\n"
            "  try {\n"
            "    final response = await _client.get(uri)\n"
            "        .timeout(const Duration(seconds: 15));\n"
            "    if (response.statusCode != 200) {\n"
            "      throw ApiException('Server membalas kode ${response.statusCode}.');\n"
            "    }\n"
            "    final body = jsonDecode(response.body) as Map<String, dynamic>;\n"
            "    final list = (body['recipes'] as List<dynamic>? ?? const []);\n"
            "    return list.map((item) =>\n"
            "        Recipe.fromJson(item as Map<String, dynamic>)).toList();\n"
            "  } catch (e) {\n"
            "    throw ApiException('Gagal memuat data. Periksa koneksi internet.');\n"
            "  }\n"
            "}"
        )
    )

    f.append(para("5.2 Penanganan loading dan error (home_page.dart)", S_H2))
    f.append(
        para(
            "State halaman Beranda memakai tiga penanda: _isLoading, "
            "_errorMessage, dan daftar _recipes. Fungsi _loadRecipes "
            "menyalakan loading, memanggil API, lalu mengisi data atau pesan "
            "error. Fungsi _buildBody memilih tampilan sesuai penanda "
            "tersebut, termasuk tampilan khusus bila hasil pencarian kosong."
        )
    )
    f.append(
        code(
            "Future<void> _loadRecipes({String query = ''}) async {\n"
            "  setState(() { _isLoading = true; _errorMessage = ''; });\n"
            "  try {\n"
            "    final result = await _apiService.fetchRecipes(query: query);\n"
            "    final favorites = await _favoriteService.getFavorites();\n"
            "    setState(() {\n"
            "      _recipes = result;\n"
            "      _favoriteIds = favorites.map((item) => item.id).toSet();\n"
            "      _isLoading = false;\n"
            "    });\n"
            "  } on ApiException catch (e) {\n"
            "    setState(() { _errorMessage = e.message; _isLoading = false; });\n"
            "  }\n"
            "}\n\n"
            "Widget _buildBody() {\n"
            "  if (_isLoading) return const Center(child: CircularProgressIndicator());\n"
            "  if (_errorMessage.isNotEmpty) return _MessageView(... 'Coba Lagi' ...);\n"
            "  if (_recipes.isEmpty) return _MessageView(... 'Tampilkan Semua' ...);\n"
            "  return RefreshIndicator(child: ListView.builder(...));\n"
            "}"
        )
    )

    f.append(para("5.3 Penyimpanan lokal (favorite_service.dart)", S_H2))
    f.append(
        para(
            "Daftar favorit disimpan sebagai satu String JSON. Saat dibaca, "
            "JSON diubah kembali menjadi objek Recipe memakai "
            "Recipe.fromJson, sehingga halaman Favorit memakai widget kartu "
            "yang sama dengan halaman Beranda."
        )
    )
    f.append(
        code(
            "Future<bool> toggleFavorite(Recipe recipe) async {\n"
            "  final favorites = await getFavorites();\n"
            "  final exists = favorites.any((item) => item.id == recipe.id);\n"
            "  if (exists) {\n"
            "    favorites.removeWhere((item) => item.id == recipe.id);\n"
            "  } else {\n"
            "    favorites.add(recipe);\n"
            "  }\n"
            "  await _saveFavorites(favorites);   // prefs.setString(JSON)\n"
            "  return !exists;\n"
            "}\n\n"
            "Future<List<Recipe>> getFavorites() async {\n"
            "  final prefs = await SharedPreferences.getInstance();\n"
            "  final raw = prefs.getString(_favoritesKey);\n"
            "  if (raw == null || raw.isEmpty) return [];\n"
            "  return (jsonDecode(raw) as List<dynamic>)\n"
            "      .map((item) => Recipe.fromJson(item as Map<String, dynamic>))\n"
            "      .toList();\n"
            "}"
        )
    )

    f.append(para("5.4 Model data (recipe.dart)", S_H2))
    f.append(
        para(
            "Satu model dipakai untuk dua sumber data sekaligus: JSON dari "
            "API dan JSON dari SharedPreferences. Nilai yang hilang diberi "
            "nilai bawaan agar aplikasi tidak berhenti karena data tidak "
            "lengkap."
        )
    )
    f.append(
        code(
            "factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(\n"
            "      id: json['id'] as int,\n"
            "      name: (json['name'] ?? '-') as String,\n"
            "      rating: (json['rating'] ?? 0).toDouble(),\n"
            "      ingredients: _toStringList(json['ingredients']),\n"
            "      ...\n"
            "    );\n\n"
            "Map<String, dynamic> toJson() => {\n"
            "      'id': id, 'name': name, 'image': image,\n"
            "      'ingredients': ingredients, 'instructions': instructions,\n"
            "      ...\n"
            "    };"
        )
    )

    # -------------------------------------------- 6. kendala & solusi
    f.append(PageBreak())
    f.append(para("6. Kendala dan Solusi", S_H1))
    f.append(
        table(
            [
                ["Kendala", "Solusi"],
                [
                    "Objek Recipe tidak bisa langsung disimpan "
                    "SharedPreferences karena hanya menerima tipe dasar.",
                    "Menambahkan toJson() pada model, lalu menyimpan "
                    "seluruh daftar sebagai satu String JSON dengan "
                    "jsonEncode dan membacanya kembali dengan jsonDecode.",
                ],
                [
                    "Ikon hati di halaman Beranda masih tampak kosong "
                    "setelah resep disimpan dari halaman Detail.",
                    "Navigator.push ditunggu dengan await, lalu data "
                    "favorit dibaca ulang (_refreshFavoriteIds) sesudah "
                    "kembali ke Beranda.",
                ],
                [
                    "Sebagian gambar resep gagal dimuat saat sinyal lemah "
                    "sehingga muncul kotak error merah.",
                    "Memakai errorBuilder pada Image.network untuk "
                    "menampilkan ikon pengganti.",
                ],
                [
                    "Pencarian dengan kata kunci yang tidak ada membuat "
                    "halaman tampak kosong tanpa keterangan.",
                    "Menambahkan tampilan khusus hasil kosong beserta "
                    "tombol Tampilkan Semua.",
                ],
                [
                    "setState terpanggil sesudah halaman ditutup sehingga "
                    "muncul peringatan di konsol.",
                    "Memeriksa properti mounted sebelum setState pada "
                    "setiap fungsi async.",
                ],
                [
                    "Permintaan API bisa menggantung lama saat jaringan "
                    "bermasalah.",
                    "Memberi .timeout(Duration(seconds: 15)) dan "
                    "membungkus kegagalan menjadi ApiException beserta "
                    "tombol Coba Lagi.",
                ],
            ],
            [7.6 * cm, 8.9 * cm],
        )
    )

    f.append(para("7. Pengujian", S_H1))
    f.append(
        para(
            "Aplikasi sudah dijalankan dan diuji, bukan sekadar ditulis "
            "kodenya. Hasil pengujian:"
        )
    )
    f.extend(
        bullets(
            [
                "<font face='Courier'>flutter analyze</font> - "
                "<b>No issues found!</b> (tidak ada peringatan maupun error).",
                "<font face='Courier'>flutter test</font> - <b>3 pengujian "
                "lulus</b> untuk model Recipe: pembacaan JSON dari API, "
                "putaran toJson/fromJson untuk penyimpanan lokal, dan data "
                "yang tidak lengkap.",
                "Uji manual: daftar resep tampil dari API, pencarian "
                "\"pizza\" mengembalikan hasil yang benar, resep tersimpan "
                "ke favorit, catatan pribadi tersimpan, dan sesudah aplikasi "
                "dimuat ulang kedua resep favorit beserta catatannya masih "
                "ada (bukti penyimpanan lokal bekerja).",
            ]
        )
    )

    f.append(para("Penutup", S_H1))
    f.append(
        para(
            "Seluruh ketentuan UTP sudah dipenuhi: aplikasi memiliki tiga "
            "halaman yang terhubung, mengambil data dari Public REST API "
            "memakai http sekaligus menyimpan favorit dan catatan memakai "
            "shared_preferences (Opsi 3), serta sudah menangani keadaan "
            "loading, error, dan data kosong. Kode sumber lengkap tersedia "
            f'di repositori GitHub: <font color="#C2410C">{GITHUB_URL}</font>.'
        )
    )

    doc.build(f, onFirstPage=header_footer, onLaterPages=header_footer)
    print(f"Laporan dibuat: {os.path.join(BASE, OUTPUT)}")


if __name__ == "__main__":
    build()
