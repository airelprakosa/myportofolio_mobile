import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Kartu tombol aksi pada halaman menu utama.
///
/// Warna latar diambil langsung dari [ItemHomepage.color], sehingga setiap
/// tombol memiliki warna unik tanpa logika pewarnaan yang berulang. Saat
/// ditekan, kartu menampilkan SnackBar berisi nama tombol tersebut, lalu
/// berpindah ke halaman yang sesuai: tombol "Tambah Proyek" membuka
/// [ProjectFormPage] setelah memastikan pengguna login, tombol
/// "Tambah Experience" membuka [ExperienceFormPage], dan tombol "Logout"
/// mencabut token sesi.
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

  /// Menjalankan aksi sesuai nama tombol setelah SnackBar ditampilkan.
  ///
  /// `Navigator.push()` dipakai agar pengguna dapat kembali ke menu dengan
  /// tombol Back perangkat/browser.
  Future<void> _handleTap(BuildContext context) async {
    _showSnackBar(context);

    switch (item.name) {
      case 'Tambah Proyek':
        // Form proyek mengirim data ke server, jadi wajib login dulu.
        final loggedIn = await ensureLoggedIn(context);
        if (!loggedIn || !context.mounted) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectFormPage()),
        );
      case 'Tambah Experience':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
        );
      case 'Logout':
        await _logout(context);
    }
  }

  /// Mencabut token jika pengguna sedang login, lalu memberi tahu pengguna.
  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    if (!auth.isLoggedIn) {
      return;
    }
    await auth.logout();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu berhasil logout.')));
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
        onTap: () => _handleTap(context),
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
