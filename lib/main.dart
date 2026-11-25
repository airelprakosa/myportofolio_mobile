import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Titik masuk aplikasi MyPortfolio Mobile.
void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

/// Root widget aplikasi yang mengatur judul, tema, halaman awal, serta
/// dependensi yang dipakai bersama oleh seluruh widget.
class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  /// Klien HTTP yang disuntikkan ke widget tree. Dijadikan parameter agar
  /// widget test dapat memakai klien palsu tanpa server sungguhan.
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    // MultiProvider menyisipkan ApiClient dan AuthState ke widget tree
    // sehingga bisa diakses lewat context.read / context.watch dari mana saja.
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthState>(
          create: (context) => AuthState(apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        // Menyembunyikan pita "DEBUG" di pojok kanan atas.
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
