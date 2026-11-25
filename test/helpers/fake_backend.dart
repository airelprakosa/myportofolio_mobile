import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Backend Django palsu untuk pengujian, dibuat dengan `MockClient` dari
/// `package:http/testing.dart` sehingga test tidak membutuhkan server asli.
///
/// Hanya akun `owner` / `secret` yang bisa login, dan POST proyek hanya
/// diterima dengan header `Authorization: Token test-token`.
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? projects})
    : projects = projects ?? [];

  static const validToken = 'test-token';

  final List<Map<String, dynamic>> projects;
  final List<http.Request> requests = [];

  /// Jika `true`, GET daftar proyek mengembalikan 500.
  bool failProjects = false;

  late final ApiClient apiClient = ApiClient(
    client: MockClient(_handle),
    baseUrl: 'http://test.local',
  );

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/projects/' && request.method == 'GET') {
      if (failProjects) {
        return http.Response('Internal Server Error', 500);
      }
      return _json(projects, 200);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (request.headers['Authorization'] != 'Token $validToken') {
        return _json({'detail': 'Invalid token.'}, 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final created = <String, dynamic>{
        ...body,
        'id': projects.length + 1,
        'star_count': 0,
        'is_starred': false,
        'starred_by_names': '',
      };
      projects.add(created);
      return _json(created, 201);
    }
    if (path == '/api/v1/auth/token/' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        return _json({'token': validToken}, 200);
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }
    if (path == '/api/v1/auth/logout/' && request.method == 'POST') {
      return http.Response('', 204);
    }
    return http.Response('Not found', 404);
  }

  http.Response _json(Object body, int status) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// Membungkus [home] dengan provider yang sama seperti `MyApp`, sehingga
/// screen dapat diuji langsung dengan backend palsu dan token awal opsional.
Widget buildTestApp(FakeBackend backend, {Widget? home, String? token}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: backend.apiClient),
      ChangeNotifierProvider<AuthState>(
        create: (context) => AuthState(backend.apiClient, initialToken: token),
      ),
    ],
    child: MaterialApp(home: home ?? const MyHomePage()),
  );
}
