import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Halaman detail satu proyek yang dipilih dari [ProjectListScreen].
///
/// Gambar proyek hanya ditampilkan jika `projectImageUrl` tidak kosong.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (project.projectImageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                project.projectImageUrl,
                height: 200,
                fit: BoxFit.cover,
                // Ditampilkan jika URL gambar rusak atau tidak dapat dimuat.
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Text('Gambar tidak dapat dimuat.'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(project.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.category, size: 18),
                label: Text(project.category),
              ),
              Chip(
                avatar: Icon(
                  project.isCompleted ? Icons.check_circle : Icons.timelapse,
                  size: 18,
                ),
                label: Text(
                  project.isCompleted ? 'Selesai' : 'Sedang berjalan',
                ),
              ),
              Chip(
                avatar: const Icon(Icons.star, size: 18),
                label: Text('${project.starCount} star'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Deskripsi', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(project.description),
        ],
      ),
    );
  }
}
