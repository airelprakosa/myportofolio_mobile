import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'helpers/fake_backend.dart';

Map<String, dynamic> _project(int id, String title) => {
  'id': id,
  'title': title,
  'description': 'Deskripsi $title',
  'category': 'Django',
  'is_completed': true,
  'project_image_url': '',
  'star_count': 0,
};

/// Memasang [widget] pada layar uji yang cukup tinggi.
Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('Daftar proyek tampil tanpa login dan membuka detail', (
    tester,
  ) async {
    final backend = FakeBackend(projects: [_project(1, 'Portfolio Web')]);
    await pumpScreen(
      tester,
      buildTestApp(backend, home: const ProjectListScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Portfolio Web'), findsOneWidget);

    await tester.tap(find.text('Portfolio Web'));
    await tester.pumpAndSettle();
    expect(find.text('Deskripsi Portfolio Web'), findsOneWidget);
  });

  testWidgets('Daftar kosong menampilkan pesan No projects found.', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      buildTestApp(FakeBackend(), home: const ProjectListScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('Error server menampilkan tombol Retry yang memuat ulang', (
    tester,
  ) async {
    final backend = FakeBackend(projects: [_project(1, 'Muncul Lagi')])
      ..failProjects = true;
    await pumpScreen(
      tester,
      buildTestApp(backend, home: const ProjectListScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    backend.failProjects = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Muncul Lagi'), findsOneWidget);
  });

  testWidgets('Login dari kartu Tambah Proyek lalu masuk ke form', (
    tester,
  ) async {
    await pumpScreen(tester, buildTestApp(FakeBackend()));

    await tester.tap(find.widgetWithText(ItemCard, 'Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Password salah menampilkan SnackBar dan tetap di Login', (
    tester,
  ) async {
    await pumpScreen(tester, buildTestApp(FakeBackend()));

    await tester.tap(find.widgetWithText(ItemCard, 'Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'salah');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Login gagal (400)'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
  });

  testWidgets('Form proyek mengirim POST ber-token dan menampilkan dialog', (
    tester,
  ) async {
    final backend = FakeBackend();
    await pumpScreen(
      tester,
      buildTestApp(
        backend,
        home: const ProjectFormPage(),
        token: FakeBackend.validToken,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Proyek'),
      'Aplikasi Mobile',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Dibuat dengan Flutter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kategori'),
      'Flutter',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    final request = backend.requests.single;
    expect(request.headers['Authorization'], 'Token test-token');
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['title'], 'Aplikasi Mobile');
    expect(backend.projects, hasLength(1));
  });

  testWidgets('Form proyek menolak isian kosong dan URL gambar tidak valid', (
    tester,
  ) async {
    final backend = FakeBackend();
    await pumpScreen(
      tester,
      buildTestApp(
        backend,
        home: const ProjectFormPage(),
        token: FakeBackend.validToken,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL Gambar Proyek (Opsional)'),
      'gambar.png',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Judul proyek tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('URL harus diawali http:// atau https:// dan valid!'),
      findsOneWidget,
    );
    expect(backend.requests, isEmpty);
  });
}
