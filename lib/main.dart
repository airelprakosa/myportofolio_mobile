import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';

/// Titik masuk aplikasi MyPortfolio Mobile.
void main() {
  runApp(const MyApp());
}

/// Root widget aplikasi yang mengatur judul, tema, dan halaman awal.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // MyHomePage memiliki konstruktor const sehingga instance-nya dapat
      // dipakai ulang tanpa dibuat ulang setiap kali MyApp di-build.
      home: const MyHomePage(),
    );
  }
}
