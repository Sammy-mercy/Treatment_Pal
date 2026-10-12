// core/network/api_client.dart
// Base HTTP client with interceptors, token attachment, and unified error handling
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client = http.Client();
  String? _authToken;
  Future<String?>? Function()? _authTokenProvider;

  static String extractErrorMessage(dynamic body) {
    if (body is! Map) {
      return 'Something went wrong. Please try again.';
    }

    if (body['error'] is Map && body['error']['message'] != null) {
      return body['error']['message'].toString();
    }

    if (body['message'] != null) {
      return body['message'].toString();
    }

    if (body['error'] != null) {
      return body['error'].toString();
    }

    return 'Something went wrong. Please try again.';
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setAuthTokenProvider(Future<String?>? Function()? provider) {
    _authTokenProvider = provider;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token =
        _authTokenProvider == null ? _authToken : await _authTokenProvider!();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static const Duration _timeout = Duration(seconds: 3);

  Future<bool> isBackendHealthy() async {
    final uri = Uri.parse(AppConstants.backendHealthUrl);
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _client
          .get(uri, headers: await _buildHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _client
          .post(
            uri,
            headers: await _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _client
          .put(
            uri,
            headers: await _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    try {
      final response = await _client
          .patch(
            uri,
            headers: await _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = extractErrorMessage(body);

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(message: message);
      case 403:
        throw ForbiddenException(message: message);
      case 404:
        throw NotFoundException(message: message);
      default:
        throw ApiException(message: message, statusCode: response.statusCode);
    }
  }

  void _handleNetworkError(dynamic e) {
    if (e is ApiException) throw e;
    if (e is TimeoutException) {
      throw ApiException(
        message: 'Unable to reach the Therapy Pal server. Please try again in a moment.',
      );
    }
    if (e is SocketException || e is http.ClientException) {
      throw ApiException(
        message: 'Unable to reach the Therapy Pal server. Please check your connection and try again.',
      );
    }
    throw ApiException(
      message: 'Connection failed. Please try again in a moment.',
    );
  }
}
