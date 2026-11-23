import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/models/experience_category.dart';
import 'package:myportofolio_mobile/utils/date_formatter.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';

void main() {
  group('ExperienceValidators.title', () {
    test('menolak isian kosong atau hanya spasi', () {
      expect(ExperienceValidators.title(null), isNotNull);
      expect(ExperienceValidators.title(''), isNotNull);
      expect(ExperienceValidators.title('   '), isNotNull);
    });

    test('menolak isian lebih dari 255 karakter', () {
      expect(ExperienceValidators.title('a' * 256), isNotNull);
      expect(ExperienceValidators.title('a' * 255), isNull);
    });

    test('menolak tag HTML dan menerima teks biasa', () {
      expect(ExperienceValidators.title('<b>Intern</b>'), isNotNull);
      expect(ExperienceValidators.title('Web Developer Intern'), isNull);
    });
  });

  group('ExperienceValidators.description', () {
    test('menolak isian kosong atau hanya spasi', () {
      expect(ExperienceValidators.description('  \n '), isNotNull);
    });

    test('menolak tag HTML dan menerima teks biasa', () {
      expect(
        ExperienceValidators.description('<script>alert(1)</script>'),
        isNotNull,
      );
      expect(ExperienceValidators.description('Membuat API Django.'), isNull);
    });
  });

  group('ExperienceValidators.thumbnail', () {
    test('boleh dikosongkan karena opsional', () {
      expect(ExperienceValidators.thumbnail(''), isNull);
      expect(ExperienceValidators.thumbnail('   '), isNull);
    });

    test('menerima URL http dan https yang valid', () {
      expect(ExperienceValidators.thumbnail('https://example.com/a.png'), isNull);
      expect(ExperienceValidators.thumbnail('http://example.com'), isNull);
    });

    test('menolak URL tanpa skema web atau tanpa host', () {
      expect(ExperienceValidators.thumbnail('example.com/a.png'), isNotNull);
      expect(ExperienceValidators.thumbnail('javascript:alert(1)'), isNotNull);
      expect(ExperienceValidators.thumbnail('https://'), isNotNull);
    });

    test('menolak URL lebih dari 200 karakter', () {
      final longUrl = 'https://example.com/${'a' * 200}';
      expect(ExperienceValidators.thumbnail(longUrl), isNotNull);
    });
  });

  group('ExperienceValidators tanggal', () {
    final today = DateTime(2026, 11, 23);

    test('tanggal mulai wajib dan tidak boleh di masa depan', () {
      expect(ExperienceValidators.startDate(null, today: today), isNotNull);
      expect(
        ExperienceValidators.startDate(DateTime(2026, 11, 24), today: today),
        isNotNull,
      );
      expect(
        ExperienceValidators.startDate(DateTime(2026, 1, 10), today: today),
        isNull,
      );
    });

    test('tanggal selesai tidak wajib jika masih berlangsung', () {
      expect(
        ExperienceValidators.endDate(null, DateTime(2026, 1, 10),
            isOngoing: true),
        isNull,
      );
    });

    test('tanggal selesai wajib jika tidak sedang berlangsung', () {
      expect(
        ExperienceValidators.endDate(null, DateTime(2026, 1, 10),
            isOngoing: false),
        isNotNull,
      );
    });

    test('tanggal selesai tidak boleh sebelum tanggal mulai', () {
      final start = DateTime(2026, 5, 1);
      expect(
        ExperienceValidators.endDate(DateTime(2026, 4, 30), start,
            isOngoing: false),
        isNotNull,
      );
      expect(
        ExperienceValidators.endDate(DateTime(2026, 5, 1), start,
            isOngoing: false),
        isNull,
      );
    });
  });

  test('formatDate menghasilkan format dd/MM/yyyy', () {
    expect(formatDate(DateTime(2026, 8, 5)), '05/08/2026');
  });

  test('ExperienceCategory sesuai pilihan model Django', () {
    expect(ExperienceCategory.choices.length, 6);
    expect(ExperienceCategory.labelOf('full-time'), 'Full-Time');
    expect(ExperienceCategory.labelOf(ExperienceCategory.defaultValue),
        'Full-Time');
  });
}
