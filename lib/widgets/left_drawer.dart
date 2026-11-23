import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Drawer menu di sisi kiri layar untuk berpindah antarhalaman aplikasi.
///
/// Dipasang pada `Scaffold` halaman menu utama, halaman form proyek, dan
/// halaman form Experience, sehingga navigasi tetap dapat diakses dari semua
/// halaman tersebut. Opsi drawer memakai `pushReplacement` agar halaman tidak
/// menumpuk di stack setiap kali pengguna berpindah lewat drawer.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // maxLines + ellipsis menjaga teks tetap muat di dalam
                // DrawerHeader yang tingginya tetap, termasuk saat ukuran
                // font perangkat diperbesar.
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Navigasi ke halaman utama portofolio
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Navigasi ke halaman tambah proyek
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Navigasi ke halaman tambah pengalaman
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceFormPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
