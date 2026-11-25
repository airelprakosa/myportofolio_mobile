import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disinkronkan dengan API Django REST Framework.
///
/// Field-nya mengikuti `ProjectSerializer` di proyek Django `myportofolio`
/// (Tutorial 07): `id`, `title`, `description`, `category`, `is_completed`,
/// `project_image_url`, dan `star_count`. `FieldRename.snake` memetakan nama
/// camelCase di Dart (misalnya `projectImageUrl`) ke kunci snake_case di JSON
/// (`project_image_url`).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = true,
    this.projectImageUrl = '',
    this.starCount = 0,
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// ID dari server (auto-increment Django). Tidak dikirim saat POST karena
  /// Django yang membuatnya.
  @JsonKey(includeToJson: false)
  final int? id;

  final String title;
  final String description;
  final String category;

  /// Status proyek, `true` jika proyek sudah selesai.
  @JsonKey(defaultValue: true)
  final bool isCompleted;

  /// URL gambar proyek; boleh kosong.
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  /// Jumlah star yang dihitung server, sehingga hanya dibaca dan tidak dikirim.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
