import 'package:material_ui/material_ui.dart';

/// Satu pilihan jenis pengalaman pada formulir Experience.
///
/// Daftar [choices] disamakan dengan `Experience.EXPERIENCE_CHOICES` pada
/// model Django di proyek web `myportofolio`, sehingga nilai [value] yang
/// dipilih di aplikasi mobile nantinya dapat dikirim langsung ke API Django.
@immutable
class ExperienceCategory {
  /// Nilai yang disimpan di database Django, misalnya `full-time`.
  final String value;

  /// Teks yang ditampilkan kepada pengguna, misalnya `Full-Time`.
  final String label;

  const ExperienceCategory(this.value, this.label);

  /// Semua jenis pengalaman yang tersedia, sesuai urutan di model Django.
  static const List<ExperienceCategory> choices = [
    ExperienceCategory('internship', 'Internship'),
    ExperienceCategory('research', 'Research'),
    ExperienceCategory('volunteer', 'Volunteer'),
    ExperienceCategory('part-time', 'Part-Time'),
    ExperienceCategory('full-time', 'Full-Time'),
    ExperienceCategory('freelance', 'Freelance'),
  ];

  /// Nilai bawaan, sama dengan `default='full-time'` pada model Django.
  static const String defaultValue = 'full-time';

  /// Mengembalikan label untuk [value], atau [value] itu sendiri jika tidak
  /// ditemukan di [choices].
  static String labelOf(String value) {
    for (final choice in choices) {
      if (choice.value == value) {
        return choice.label;
      }
    }
    return value;
  }
}
