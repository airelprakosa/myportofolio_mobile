import 'package:material_ui/material_ui.dart';

/// Model data untuk satu tombol aksi pada halaman menu utama.
///
/// Setiap tombol menyimpan [name], [icon], dan [color] miliknya sendiri,
/// sehingga `ItemCard` cukup membaca atribut ini tanpa percabangan `if-else`
/// untuk menentukan warna. Konstruktornya `const` agar daftar tombol dibuat
/// sekali saat kompilasi dan tidak dialokasikan ulang setiap kali halaman
/// di-build.
@immutable
class ItemHomepage {
  /// Label tombol. Teks ini juga dipakai pada pesan SnackBar.
  final String name;

  /// Ikon Material yang ditampilkan di atas label tombol.
  final IconData icon;

  /// Warna latar kartu tombol. Setiap tombol diberi warna yang berbeda.
  final Color color;

  /// Penjelasan singkat aksi tombol yang ditampilkan sebagai tooltip.
  ///
  /// Boleh dikosongkan; jika kosong, tooltip tidak ditampilkan.
  final String description;

  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.description = '',
  });
}
