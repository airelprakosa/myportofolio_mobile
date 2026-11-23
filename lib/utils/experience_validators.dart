/// Kumpulan aturan validasi untuk formulir Experience.
///
/// Aturan ini dipisahkan dari halaman formulir supaya logika validasi
/// mudah dibaca, dapat diuji dengan unit test tanpa membangun widget, dan
/// konsisten dengan aturan model `Experience` serta `ExperienceForm` di
/// proyek Django. Setiap fungsi mengembalikan pesan kesalahan, atau `null`
/// jika nilainya valid (sesuai kontrak `FormField.validator`).
class ExperienceValidators {
  ExperienceValidators._();

  /// Batas panjang posisi/peran, sama dengan `max_length=255` di Django.
  static const int titleMaxLength = 255;

  /// Batas panjang URL thumbnail, sama dengan bawaan `URLField` Django (200).
  static const int thumbnailMaxLength = 200;

  /// Pola sederhana untuk mendeteksi tag HTML seperti `<script>` atau `<b>`.
  static final RegExp _htmlTagPattern = RegExp(r'<[^>]*>');

  /// Posisi/peran wajib diisi, maksimal [titleMaxLength] karakter, dan tidak
  /// boleh berisi tag HTML (meniru `strip_tags` pada `clean_title` Django).
  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Posisi / peran tidak boleh kosong!';
    }
    if (text.length > titleMaxLength) {
      return 'Posisi / peran maksimal $titleMaxLength karakter!';
    }
    if (_htmlTagPattern.hasMatch(text)) {
      return 'Posisi / peran tidak boleh berisi tag HTML!';
    }
    return null;
  }

  /// Deskripsi wajib diisi dan tidak boleh berisi tag HTML (meniru
  /// `clean_description` pada `ExperienceForm` Django).
  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Deskripsi pengalaman tidak boleh kosong!';
    }
    if (_htmlTagPattern.hasMatch(text)) {
      return 'Deskripsi tidak boleh berisi tag HTML!';
    }
    return null;
  }

  /// URL thumbnail bersifat opsional. Jika diisi, harus berupa URL `http`
  /// atau `https` yang memiliki host, dan maksimal [thumbnailMaxLength]
  /// karakter. Skema lain seperti `javascript:` ditolak.
  static String? thumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.length > thumbnailMaxLength) {
      return 'URL thumbnail maksimal $thumbnailMaxLength karakter!';
    }
    final uri = Uri.tryParse(text);
    final isWebUrl = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      return 'URL harus diawali http:// atau https:// dan valid!';
    }
    return null;
  }

  /// Tanggal mulai wajib dipilih dan tidak boleh melewati hari ini.
  ///
  /// [today] dapat diisi saat pengujian; jika kosong, dipakai tanggal hari
  /// ini.
  static String? startDate(DateTime? value, {DateTime? today}) {
    if (value == null) {
      return 'Tanggal mulai wajib dipilih!';
    }
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    if (value.isAfter(todayDate)) {
      return 'Tanggal mulai tidak boleh di masa depan!';
    }
    return null;
  }

  /// Tanggal selesai tidak diperlukan jika pengalaman masih berlangsung
  /// (setara `ended_at = None` di Django). Jika tidak, tanggal selesai wajib
  /// dipilih dan tidak boleh lebih awal dari tanggal mulai.
  static String? endDate(
    DateTime? value,
    DateTime? start, {
    required bool isOngoing,
  }) {
    if (isOngoing) {
      return null;
    }
    if (value == null) {
      return 'Pilih tanggal selesai atau tandai sebagai masih berlangsung!';
    }
    if (start != null && value.isBefore(start)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }
}
