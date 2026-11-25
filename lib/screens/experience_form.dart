import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience_category.dart';
import 'package:myportofolio_mobile/utils/date_formatter.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan pengalaman (Experience) baru.
///
/// Field-nya mengikuti model `Experience` di proyek Django: posisi/peran
/// (`title`), deskripsi, jenis pengalaman (`category`), URL thumbnail, serta
/// tanggal mulai dan selesai (`started_at`, `ended_at`). Aturan validasinya
/// dipisah ke [ExperienceValidators]. Data belum dikirim ke server; setelah
/// lolos validasi, isian ditampilkan sebagai ringkasan di dalam dialog.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  /// Lebar maksimum formulir agar tetap nyaman dibaca di layar lebar.
  static const double _maxFormWidth = 720.0;

  /// Batas paling awal yang bisa dipilih pada date picker.
  static final DateTime _earliestDate = DateTime(1990);

  /// Kunci untuk memanggil `validate()` dan `reset()` pada form.
  final _formKey = GlobalKey<FormState>();

  /// Controller untuk menampilkan tanggal terpilih pada field tanggal.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _title = '';
  String _description = '';
  String _category = ExperienceCategory.defaultValue;
  String _thumbnail = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  /// Setelah tombol Simpan pertama kali ditekan, pesan kesalahan diperbarui
  /// langsung saat pengguna mengetik.
  bool _hasTriedSubmit = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Tanggal hari ini tanpa komponen jam, dipakai sebagai batas akhir picker.
  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  /// Membuka date picker untuk tanggal mulai.
  ///
  /// Jika tanggal selesai yang sudah dipilih menjadi lebih awal dari tanggal
  /// mulai yang baru, tanggal selesai dikosongkan agar tidak tersimpan dalam
  /// kondisi tidak valid.
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? _today,
      firstDate: _earliestDate,
      lastDate: _today,
      helpText: 'Pilih tanggal mulai',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _startDate = picked;
      _startDateController.text = formatDate(picked);
      final end = _endDate;
      if (end != null && end.isBefore(picked)) {
        _endDate = null;
        _endDateController.clear();
      }
    });
  }

  /// Membuka date picker untuk tanggal selesai.
  ///
  /// Tanggal paling awal yang bisa dipilih adalah tanggal mulai, sehingga
  /// urutan tanggal yang salah sudah dicegah sejak dari picker.
  Future<void> _pickEndDate() async {
    final firstDate = _startDate ?? _earliestDate;
    var initialDate = _endDate ?? _today;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: _today,
      helpText: 'Pilih tanggal selesai',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _endDate = picked;
      _endDateController.text = formatDate(picked);
    });
  }

  /// Mengaktifkan atau menonaktifkan status "masih berlangsung".
  void _setOngoing(bool value) {
    setState(() {
      _isOngoing = value;
      if (value) {
        _endDate = null;
        _endDateController.clear();
      }
    });
  }

  /// Mengosongkan seluruh isian dan pesan kesalahan.
  void _resetForm() {
    setState(() {
      _title = '';
      _description = '';
      _category = ExperienceCategory.defaultValue;
      _thumbnail = '';
      _startDate = null;
      _endDate = null;
      _isOngoing = false;
      _hasTriedSubmit = false;
      _startDateController.clear();
      _endDateController.clear();
    });
    // reset() dijalankan setelah frame berikutnya agar dropdown kembali ke
    // nilai bawaan yang baru saja diatur di atas.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.reset();
    });
  }

  /// Memvalidasi semua field, lalu menampilkan ringkasan jika semuanya valid.
  void _submit() {
    setState(() {
      _hasTriedSubmit = true;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Experience berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posisi / Peran: ${_title.trim()}'),
                Text('Deskripsi: ${_description.trim()}'),
                Text(
                  'Jenis Pengalaman: ${ExperienceCategory.labelOf(_category)}',
                ),
                Text(
                  'Thumbnail: '
                  '${_thumbnail.trim().isEmpty ? '-' : _thumbnail.trim()}',
                ),
                Text('Tanggal Mulai: ${formatDate(_startDate!)}'),
                Text(
                  'Tanggal Selesai: '
                  '${_isOngoing ? 'Masih berlangsung' : formatDate(_endDate!)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  /// Dekorasi input yang seragam untuk semua field formulir.
  InputDecoration _decoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Warna dan gaya AppBar disamakan dengan halaman utama.
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _hasTriedSubmit
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          // SingleChildScrollView menjaga semua field dan tombol Simpan tetap
          // dapat dijangkau di layar sempit atau saat papan ketik terbuka.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === Posisi / Peran (title) ===
                    TextFormField(
                      decoration: _decoration(
                        label: 'Posisi / Peran',
                        hint: 'Contoh: Web Developer Intern',
                      ),
                      maxLength: ExperienceValidators.titleMaxLength,
                      textInputAction: TextInputAction.next,
                      onChanged: (String value) {
                        setState(() {
                          _title = value;
                        });
                      },
                      validator: ExperienceValidators.title,
                    ),
                    const SizedBox(height: 8.0),

                    // === Deskripsi (description) ===
                    TextFormField(
                      decoration: _decoration(
                        label: 'Deskripsi Pengalaman',
                        hint: 'Ceritakan pengalamanmu di sini...',
                      ),
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      onChanged: (String value) {
                        setState(() {
                          _description = value;
                        });
                      },
                      validator: ExperienceValidators.description,
                    ),
                    const SizedBox(height: 16.0),

                    // === Jenis Pengalaman (category) ===
                    DropdownButtonFormField<String>(
                      decoration: _decoration(label: 'Jenis Pengalaman'),
                      initialValue: _category,
                      items: ExperienceCategory.choices
                          .map(
                            (choice) => DropdownMenuItem<String>(
                              value: choice.value,
                              child: Text(choice.label),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category =
                              newValue ?? ExperienceCategory.defaultValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // === URL Thumbnail (opsional) ===
                    TextFormField(
                      decoration: _decoration(
                        label: 'URL Thumbnail (Opsional)',
                        hint: 'Contoh: https://drive.google.com/...',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onChanged: (String value) {
                        setState(() {
                          _thumbnail = value;
                        });
                      },
                      validator: ExperienceValidators.thumbnail,
                    ),
                    const SizedBox(height: 16.0),

                    // === Tanggal Mulai (started_at) ===
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: _decoration(
                        label: 'Tanggal Mulai',
                        hint: 'Ketuk untuk memilih tanggal',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: _pickStartDate,
                      validator: (_) =>
                          ExperienceValidators.startDate(_startDate),
                    ),
                    const SizedBox(height: 8.0),

                    // === Status masih berlangsung (ended_at = null) ===
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih berlangsung'),
                      subtitle: const Text(
                        'Aktifkan jika pengalaman ini belum selesai.',
                      ),
                      value: _isOngoing,
                      onChanged: _setOngoing,
                    ),
                    const SizedBox(height: 8.0),

                    // === Tanggal Selesai (ended_at) ===
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      enabled: !_isOngoing,
                      decoration: _decoration(
                        label: 'Tanggal Selesai',
                        hint: _isOngoing
                            ? 'Masih berlangsung'
                            : 'Ketuk untuk memilih tanggal',
                        suffixIcon: const Icon(Icons.event),
                      ),
                      onTap: _pickEndDate,
                      validator: (_) => ExperienceValidators.endDate(
                        _endDate,
                        _startDate,
                        isOngoing: _isOngoing,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // === Tombol Reset dan Simpan ===
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _submit,
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
