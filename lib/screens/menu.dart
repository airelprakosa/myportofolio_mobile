import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Halaman menu utama aplikasi MyPortfolio Mobile.
///
/// Halaman ini hanya menampilkan data yang tetap (identitas pemilik dan daftar
/// tombol aksi), sehingga dibuat sebagai [StatelessWidget] dengan konstruktor
/// `const`. Komponen kartunya dipisah ke `widgets/` dan model datanya ke
/// `models/` agar berkas ini fokus pada susunan halaman.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  /// Lebar maksimum konten agar tampilan tetap proporsional di layar lebar
  /// (misalnya saat dijalankan di Chrome).
  static const double _maxContentWidth = 720.0;

  /// Batas lebar untuk menampilkan tombol dalam 4 kolom; di bawahnya 2 kolom.
  static const double _wideLayoutBreakpoint = 600.0;

  /// NPM pemilik portofolio.
  final String npm = '2506657251';

  /// Nama lengkap pemilik portofolio.
  final String nama = 'Raden Stanislaus Airell Prakosa Sinaga';

  /// Kelas PBP pemilik portofolio.
  final String kelas = 'E';

  /// Daftar tombol aksi portofolio. Setiap tombol memiliki warna latar yang
  /// berbeda dan kontras satu sama lain.
  final List<ItemHomepage> items = const [
    ItemHomepage(
      'Lihat Experience',
      Icons.work,
      Color(0xFF1565C0), // biru
      description: 'Lihat daftar pengalaman (Experience) di portofolio',
    ),
    ItemHomepage(
      'Tambah Experience',
      Icons.add_circle,
      Color(0xFF2E7D32), // hijau
      description: 'Tambahkan pengalaman baru ke portofolio',
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.create_new_folder,
      Color(0xFF6A1B9A), // ungu
      description: 'Tambahkan proyek baru ke portofolio',
    ),
    ItemHomepage(
      'Logout',
      Icons.logout,
      Color(0xFFC62828), // merah
      description: 'Keluar dari akun portofolio',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Scaffold menyediakan struktur visual dasar halaman (AppBar, body,
    // dan tempat SnackBar ditampilkan).
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // SingleChildScrollView mencegah overflow ketika layar pendek atau
      // ketika orientasi perangkat diputar.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IntrinsicHeight membuat ketiga InfoCard sama tinggi
                // walaupun isi kartu Name lebih panjang dari yang lain.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'NPM',
                          content: npm,
                          icon: Icons.badge,
                        ),
                      ),
                      Expanded(
                        child: InfoCard(
                          title: 'Name',
                          content: nama,
                          icon: Icons.person,
                        ),
                      ),
                      Expanded(
                        child: InfoCard(
                          title: 'Class',
                          content: kelas,
                          icon: Icons.class_,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Selamat datang di MyPortfolio Mobile!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Pilih menu di bawah untuk mengelola portofolio kamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16.0),
                // LayoutBuilder menyesuaikan jumlah kolom dengan lebar layar:
                // 2 kolom di ponsel, 4 kolom di layar lebar.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth >= _wideLayoutBreakpoint ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      // shrinkWrap + NeverScrollableScrollPhysics agar grid
                      // mengikuti tinggi isinya dan ikut digulir bersama
                      // halaman, bukan menggulir sendiri.
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: items.map((item) => ItemCard(item)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
