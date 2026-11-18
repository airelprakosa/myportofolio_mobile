import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Memasang aplikasi pada layar uji yang cukup tinggi agar seluruh tombol
/// terlihat tanpa perlu menggulir.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MyApp());
}

void main() {
  const page = MyHomePage();

  testWidgets('InfoCard menampilkan identitas pemilik portofolio', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text(page.npm), findsOneWidget);
    expect(find.text(page.nama), findsOneWidget);
    expect(find.text(page.kelas), findsOneWidget);
  });

  test('Minimal ada 3 tombol aksi dan warnanya unik', () {
    final colors = page.items.map((item) => item.color).toSet();

    expect(page.items.length, greaterThanOrEqualTo(3));
    expect(colors.length, page.items.length);
  });

  for (final item in page.items) {
    testWidgets('Tombol ${item.name} berwarna sesuai dan memunculkan SnackBar', (
      tester,
    ) async {
      await pumpApp(tester);

      final card = find.widgetWithText(ItemCard, item.name);
      final material = tester.widget<Material>(
        find.descendant(of: card, matching: find.byType(Material)).first,
      );
      expect(material.color, item.color);

      await tester.tap(card);
      await tester.pump();

      expect(find.text(ItemCard.snackBarMessage(item.name)), findsWidgets);
    });
  }

  testWidgets('Tombol Tambah Proyek membuka halaman form proyek', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ItemCard, 'Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
  });
}
