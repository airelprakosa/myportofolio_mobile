import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'helpers/fake_backend.dart';

void main() {
  group('Project JSON', () {
    test('fromJson memetakan kunci snake_case dan nilai bawaan', () {
      final project = Project.fromJson({
        'id': 7,
        'title': 'Portfolio',
        'description': 'Website pribadi',
        'category': 'Django',
        'is_completed': false,
        'project_image_url': null,
        'star_count': 3,
      });

      expect(project.id, 7);
      expect(project.isCompleted, isFalse);
      expect(project.projectImageUrl, '');
      expect(project.starCount, 3);
    });

    test('toJson tidak mengirim id dan star_count', () {
      const project = Project(
        title: 'Mobile',
        description: 'Aplikasi Flutter',
        category: 'Flutter',
        id: 1,
        starCount: 5,
      );

      final json = project.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json['is_completed'], isTrue);
      expect(json['project_image_url'], '');
    });
  });

  group('ApiClient', () {
    test('getProjects mengambil daftar proyek tanpa token', () async {
      final backend = FakeBackend(
        projects: [
          {
            'id': 1,
            'title': 'Portfolio',
            'description': 'Website',
            'category': 'Django',
            'is_completed': true,
            'project_image_url': '',
          },
        ],
      );

      final projects = await backend.apiClient.getProjects();

      expect(projects.single.title, 'Portfolio');
      expect(backend.requests.single.headers['Authorization'], isNull);
    });

    test('createProject mengirim header token dan body JSON', () async {
      final backend = FakeBackend();
      const project = Project(
        title: 'Baru',
        description: 'Dari Flutter',
        category: 'Mobile',
      );

      final created = await backend.apiClient.createProject(
        project,
        token: FakeBackend.validToken,
      );

      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token test-token');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['title'], 'Baru');
      expect(body.containsKey('id'), isFalse);
      expect(created.id, 1);
    });

    test('createProject dengan token salah melempar ApiException 401', () {
      final backend = FakeBackend();
      const project = Project(title: 'A', description: 'B', category: 'C');

      expect(
        backend.apiClient.createProject(project, token: 'salah'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('obtainToken mengembalikan token atau melempar 400', () async {
      final backend = FakeBackend();

      expect(
        await backend.apiClient.obtainToken('owner', 'secret'),
        'test-token',
      );
      expect(
        backend.apiClient.obtainToken('owner', 'salah'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('getProjects melempar ApiException saat server error', () {
      final backend = FakeBackend()..failProjects = true;

      expect(
        backend.apiClient.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('userMessage tidak membocorkan body respons mentah', () {
      const error = ApiException(500, '<html>Traceback ...</html>');

      expect(error.userMessage, isNot(contains('Traceback')));
      expect(const ApiException(401, '').userMessage, contains('login'));
    });
  });

  group('AuthState', () {
    test('login menyimpan token dan memberi tahu listener', () async {
      final auth = AuthState(FakeBackend().apiClient);
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'test-token');
      expect(notified, 1);
    });

    test('logout mencabut token di server lalu menghapusnya', () async {
      final backend = FakeBackend();
      final auth = AuthState(backend.apiClient, initialToken: 'test-token');

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      final request = backend.requests.single;
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.headers['Authorization'], 'Token test-token');
    });

    test('logout tetap menghapus token walau server menolak', () async {
      final auth = AuthState(
        ApiClient(baseUrl: 'http://test.local', client: _failingClient()),
        initialToken: 'kedaluwarsa',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });
  });
}

/// Klien yang selalu mengembalikan 401, meniru token yang sudah tidak valid.
MockClient _failingClient() =>
    MockClient((request) async => http.Response('Invalid token.', 401));
