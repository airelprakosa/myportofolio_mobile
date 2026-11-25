import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman form untuk menambahkan proyek baru ke backend Django.
///
/// Field-nya mengikuti `ProjectSerializer` Tutorial 07 milik proyek Django
/// ini (`title`, `description`, `category`, `is_completed`, dan
/// `project_image_url`). Data dikirim dengan POST ber-token ke
/// `/api/v1/projects/`, sehingga pengguna harus login terlebih dahulu.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  /// Kunci untuk mengakses state form (validasi dan reset).
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isCompleted = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Validator untuk field wajib dengan batas panjang dari model Django.
  String? Function(String?) _requiredField(String label, int maxLength) {
    return (String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) {
        return '$label tidak boleh kosong!';
      }
      if (text.length > maxLength) {
        return '$label maksimal $maxLength karakter!';
      }
      return null;
    };
  }

  /// URL gambar bersifat opsional, tetapi jika diisi harus berupa URL
  /// `http`/`https` yang valid (sesuai `URLField(max_length=500)` di Django).
  String? _validateImageUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.length > 500) {
      return 'URL gambar maksimal 500 karakter!';
    }
    final uri = Uri.tryParse(text);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      return 'URL harus diawali http:// atau https:// dan valid!';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _imageUrlController.clear();
    setState(() {
      _isCompleted = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pastikan pengguna sudah login sebelum mengirim data ke server.
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) {
      return;
    }
    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) {
      return;
    }

    final newProject = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      isCompleted: _isCompleted,
      projectImageUrl: _imageUrlController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });
    Project? created;
    ApiException? apiError;
    try {
      created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
    } on ApiException catch (error) {
      apiError = error;
    } catch (_) {
      if (mounted) {
        _showMessage('Tidak dapat terhubung ke server. Coba lagi nanti.');
      }
    } finally {
      // Loading dimatikan sebelum dialog atau halaman login muncul, supaya
      // spinner di tombol Save tidak terus berputar di belakangnya.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
    if (!mounted) {
      return;
    }

    if (created != null) {
      await _showSuccessDialog(created);
      if (mounted) {
        _resetForm();
      }
      return;
    }
    if (apiError == null) {
      return;
    }
    if (apiError.statusCode == 401) {
      // Token sudah tidak berlaku: logout lalu minta login ulang.
      await auth.logout();
      if (!mounted) {
        return;
      }
      _showMessage('Sesi berakhir. Silakan login kembali.');
      await ensureLoggedIn(context);
    } else {
      _showMessage(
        'Gagal menyimpan proyek (${apiError.statusCode}): '
        '${apiError.userMessage}',
      );
    }
  }

  /// Menampilkan data proyek yang berhasil dibuat server (201 Created).
  Future<void> _showSuccessDialog(Project project) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${project.id ?? '-'}'),
                Text('Judul: ${project.title}'),
                Text('Deskripsi: ${project.description}'),
                Text('Kategori: ${project.category}'),
                Text(
                  'Status: ${project.isCompleted ? 'Selesai' : 'Sedang berjalan'}',
                ),
                Text(
                  'Gambar: '
                  '${project.projectImageUrl.isEmpty ? '-' : project.projectImageUrl}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// Dekorasi input yang seragam untuk semua field formulir.
  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: _decoration(
                    'Judul Proyek',
                    hint: 'Contoh: Aplikasi Portofolio Mobile',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _requiredField('Judul proyek', 255),
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _decoration(
                    'Deskripsi Proyek',
                    hint: 'Ceritakan tujuan dan fitur proyek ini',
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi proyek tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _categoryController,
                  decoration: _decoration(
                    'Kategori',
                    hint: 'Contoh: Web Development, Mobile, Data Science',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _requiredField('Kategori', 100),
                ),
              ),

              // === Project Image URL (opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    'URL Gambar Proyek (Opsional)',
                    hint: 'https://...',
                  ),
                  validator: _validateImageUrl,
                ),
              ),

              // === Is Completed ===
              SwitchListTile(
                title: const Text('Proyek sudah selesai'),
                value: _isCompleted,
                onChanged: (bool value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
