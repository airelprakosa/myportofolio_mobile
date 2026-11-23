/// Mengubah [date] menjadi teks `dd/MM/yyyy`, misalnya `05/08/2026`.
///
/// Ditulis manual agar proyek tidak perlu menambah dependensi `intl` hanya
/// untuk menampilkan tanggal pada formulir dan dialog ringkasan.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
