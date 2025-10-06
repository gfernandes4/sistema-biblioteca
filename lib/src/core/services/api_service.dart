import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../errors/failures.dart';

/// Serviço para comunicação com a API
class ApiService {
  final http.Client _client;
  final Logger _logger;
  String? _authToken;

  ApiService({
    http.Client? client,
    Logger? logger,
  }) : _client = client ?? http.Client(),
       _logger = logger ?? Logger();

  /// Define o token de autenticação
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Remove o token de autenticação
  void clearAuthToken() {
    _authToken = null;
  }

  /// Headers padrão com autenticação se disponível
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Realiza requisição GET
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParameters}) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      _logger.d('GET: $uri');

      final response = await _client.get(uri, headers: _headers);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(message: 'Sem conexão com a internet');
    } catch (e) {
      _logger.e('Erro na requisição GET: $e');
      throw NetworkFailure(message: 'Erro na requisição: $e');
    }
  }

  /// Realiza requisição POST
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(endpoint);
      _logger.d('POST: $uri');
      _logger.d('Body: ${jsonEncode(body)}');

      final response = await _client.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(message: 'Sem conexão com a internet');
    } catch (e) {
      _logger.e('Erro na requisição POST: $e');
      throw NetworkFailure(message: 'Erro na requisição: $e');
    }
  }

  /// Realiza requisição PUT
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(endpoint);
      _logger.d('PUT: $uri');

      final response = await _client.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(message: 'Sem conexão com a internet');
    } catch (e) {
      _logger.e('Erro na requisição PUT: $e');
      throw NetworkFailure(message: 'Erro na requisição: $e');
    }
  }

  /// Realiza requisição DELETE
  Future<void> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      _logger.d('DELETE: $uri');

      final response = await _client.delete(uri, headers: _headers);
      _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(message: 'Sem conexão com a internet');
    } catch (e) {
      _logger.e('Erro na requisição DELETE: $e');
      throw NetworkFailure(message: 'Erro na requisição: $e');
    }
  }

  /// Upload de arquivo
  Future<dynamic> uploadFile(String endpoint, File file, {Map<String, String>? fields}) async {
    try {
      final uri = _buildUri(endpoint);
      _logger.d('UPLOAD: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // O backend Flask espera o campo multipart com o nome 'arquivo'
      final multipartFile = await http.MultipartFile.fromPath(
        'arquivo',
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(message: 'Sem conexão com a internet');
    } catch (e) {
      _logger.e('Erro no upload: $e');
      throw BookUploadFailure(message: 'Erro no upload: $e');
    }
  }

  /// Constrói URI com base URL e endpoint
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final url = '${ApiConstants.baseUrl}$endpoint';
    return Uri.parse(url).replace(queryParameters: queryParameters);
  }
 

  /// Trata a resposta da API
  dynamic _handleResponse(http.Response response) {
    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return {};
        }
        return jsonDecode(response.body);
      case 400:
        final body = _tryDecodeJson(response.body);
        throw ValidationFailure(
          message: body['message'] ?? 'Dados inválidos',
          code: response.statusCode,
        );
      case 401:
        throw const UnauthorizedFailure();
      case 404:
        final body = _tryDecodeJson(response.body);
        throw BookNotFoundFailure(
          message: body['message'] ?? 'Recurso não encontrado',
          code: response.statusCode,
        );
      case 500:
      default:
        final body = _tryDecodeJson(response.body);
        throw ServerFailure(
          message: body['message'] ?? 'Erro interno do servidor',
          code: response.statusCode,
        );
    }
  }

  /// Tenta decodificar JSON, retorna map vazio se falhar
  Map<String, dynamic> _tryDecodeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Limpa recursos
  void dispose() {
    _client.close();
  }
}
