import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  ApiService._();

  String? _token;
  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<File> imageFiles,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    debugPrint('[API] POST multipart: $uri');
    debugPrint('[API] Fields: $fields');
    debugPrint('[API] Images: ${imageFiles.length} files');
    debugPrint('[API] Token: ${_token != null ? "present" : "null"}');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_authHeaders);
    fields.forEach((k, v) => request.fields[k] = v);
    for (final f in imageFiles) {
      final ext = f.path.toLowerCase().split('.').last;
      final mime = ext == 'png'
          ? 'image/png'
          : ext == 'gif'
              ? 'image/gif'
              : ext == 'webp'
                  ? 'image/webp'
                  : 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        f.path,
        contentType: MediaType.parse(mime),
      ));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    debugPrint('[API] Response status: ${res.statusCode}');
    debugPrint('[API] Response body (first 500 chars): ${res.body.length > 500 ? res.body.substring(0, 500) : res.body}');
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    debugPrint('[API] GET $uri');
    final res = await http.get(uri, headers: _headers);
    debugPrint('[API] GET $path status: ${res.statusCode}');
    return _handleResponse(res);
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> data = <String, dynamic>{};
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        data = decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } catch (e, st) {
        debugPrint('[API] JSON decode error: $e');
        debugPrint('[API] Stack: $st');
        if (res.body.trimLeft().startsWith('<')) {
          debugPrint('[API] Server returned HTML (not JSON) - status ${res.statusCode}');
          throw ApiException(
            res.statusCode == 404
                ? 'Serveur non trouvé. Vérifiez que le backend tourne sur le port 3000.'
                : 'Erreur serveur (${res.statusCode}). Vérifiez la connexion.',
            res.statusCode,
          );
        }
        rethrow;
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }
    debugPrint('[API] Error response: status=${res.statusCode} message=${data['message']}');
    throw ApiException(
      data['message']?.toString() ?? 'Erreur inconnue (${res.statusCode})',
      res.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
