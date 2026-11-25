import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception yang dilempar ketika request API mengembalikan status non-2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;

  /// Isi body respons mentah dari server, berguna untuk debugging.
  final String message;

  /// Pesan ramah pengguna berdasarkan [statusCode].
  ///
  /// Body respons mentah tidak ditampilkan ke pengguna karena bisa berisi
  /// halaman error HTML atau stack trace Django saat `DEBUG=True`.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Data tidak valid atau username/password salah.';
      case 401:
        return 'Sesi login tidak valid. Silakan login kembali.';
      case 403:
        return 'Akun ini tidak memiliki izin untuk melakukan aksi tersebut.';
      case 404:
        return 'Data tidak ditemukan.';
      default:
        if (statusCode >= 500) {
          return 'Terjadi kesalahan pada server. Coba lagi nanti.';
        }
        return 'Permintaan gagal.';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client untuk backend Django REST Framework MyPortfolio.
///
/// Semua pemanggilan jaringan dikumpulkan di sini agar screen dan widget
/// hanya bertugas menampilkan antarmuka. Kunci header ditulis sebagai string
/// biasa (bukan `HttpHeaders` dari `dart:io`) supaya tetap bisa dibangun untuk
/// Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Mengambil seluruh proyek. Endpoint ini publik sehingga tidak perlu token.
  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);
    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Membuat proyek baru dengan token milik pengguna yang sedang login.
  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);
    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// Menukar username dan password menjadi token autentikasi.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final decoded = _decode(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  /// Mencabut token di server (204 No Content).
  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  /// Mendekode body sebagai UTF-8 agar karakter non-ASCII tidak rusak, karena
  /// Django tidak selalu menyertakan `charset` di header `Content-Type`.
  dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
