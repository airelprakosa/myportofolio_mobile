import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'helpers/fake_backend.dart';

/// Memasang [widget] pada layar uji yang cukup tinggi.
Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

/// Membuka drawer pada halaman yang sedang tampil.
Future<void> openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
  await tester.pumpAndSettle();
}

/// Menekan tombol Simpan setelah memastikan tombolnya terlihat.
Future<void> tapSave(WidgetTester tester) async {
  final saveButton = find.text('Simpan');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Kartu Tambah Experience membuka form dan bisa kembali', (
    tester,
  ) async {
    await pumpScreen(tester, MyApp(apiClient: FakeBackend().apiClient));

    await tester.tap(find.widgetWithText(ItemCard, 'Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    // Meniru tombol Back perangkat/browser.
    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer membuka form Experience dan opsi Home kembali ke menu', (
    tester,
  ) async {
    await pumpScreen(tester, MyApp(apiClient: FakeBackend().apiClient));

    await openDrawer(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    await openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Simpan dengan isian kosong menampilkan pesan kesalahan', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      buildTestApp(FakeBackend(), home: const ExperienceFormPage()),
    );

    await tapSave(tester);

    expect(find.text('Posisi / peran tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Deskripsi pengalaman tidak boleh kosong!'),
      findsOneWidget,
    );
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Simpan dengan isian valid menampilkan dialog ringkasan', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      buildTestApp(FakeBackend(), home: const ExperienceFormPage()),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Posisi / Peran'),
      'Web Developer Intern',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Pengalaman'),
      'Membangun REST API dengan Django.',
    );

    // Memilih tanggal mulai (hari ini) lewat date picker.
    await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Menandai pengalaman sebagai masih berlangsung.
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapSave(tester);

    expect(find.text('Experience berhasil disimpan!'), findsOneWidget);
    expect(find.text('Posisi / Peran: Web Developer Intern'), findsOneWidget);
    expect(find.text('Jenis Pengalaman: Full-Time'), findsOneWidget);
    expect(find.text('Tanggal Selesai: Masih berlangsung'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Add Experience Form'), findsOneWidget);
  });
}
