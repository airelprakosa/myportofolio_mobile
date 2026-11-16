import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';

/// Kartu tombol aksi pada halaman menu utama.
///
/// Warna latar diambil langsung dari [ItemHomepage.color], sehingga setiap
/// tombol memiliki warna unik tanpa logika pewarnaan yang berulang. Saat
/// ditekan, kartu menampilkan SnackBar berisi nama tombol tersebut.
class ItemCard extends StatelessWidget {
  /// Data tombol (nama, ikon, warna, dan deskripsi) yang ditampilkan.
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  /// Membuat pesan SnackBar sesuai nama tombol yang ditekan.
  ///
  /// Dibuat `static` agar teks yang sama dapat dipakai ulang di widget test.
  static String snackBarMessage(String name) {
    return 'Kamu telah menekan tombol $name!';
  }

  /// Menampilkan SnackBar dengan ikon dan warna yang sama seperti tombolnya.
  ///
  /// SnackBar sebelumnya ditutup terlebih dahulu supaya pesan tidak menumpuk
  /// ketika pengguna menekan beberapa tombol secara berurutan.
  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(item.icon, color: Colors.white),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  snackBarMessage(item.name),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: item.color,
          // Floating agar SnackBar tidak menempel di tepi bawah layar.
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final card = Material(
      // Warna latar unik untuk setiap tombol, diambil dari model data.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2.0,
      child: InkWell(
        // borderRadius yang sama agar efek ripple tidak keluar dari sudut.
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSnackBar(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 30.0),
              const SizedBox(height: 6.0),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Tooltip muncul saat kursor diarahkan (web/desktop) atau saat kartu
    // ditekan lama (mobile), menjelaskan fungsi tombol.
    if (item.description.isEmpty) {
      return card;
    }
    return Tooltip(message: item.description, child: card);
  }
}
