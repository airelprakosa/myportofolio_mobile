import 'package:material_ui/material_ui.dart';

/// Kartu ringkas yang menampilkan satu informasi identitas pemilik portofolio.
///
/// Dipakai tiga kali di halaman menu (NPM, Name, dan Class) sehingga
/// tampilannya konsisten tanpa menulis ulang kode kartu yang sama.
class InfoCard extends StatelessWidget {
  /// Judul kartu, misalnya `NPM`.
  final String title;

  /// Isi informasi yang ditampilkan di bawah judul.
  final String content;

  /// Ikon kecil di atas judul untuk memperjelas jenis informasi.
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Bayangan tipis agar kartu terlihat terpisah dari latar halaman.
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 8.0),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            // textAlign center supaya isi yang panjang (misalnya nama
            // lengkap) tetap rapi ketika turun ke beberapa baris.
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
