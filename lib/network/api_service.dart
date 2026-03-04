import 'dart:convert';

import 'package:http/http.dart' as http;

/// Common API service for HTTP calls. Configure base URL and default headers here.
class ApiService {
  ApiService({
    String? baseUrl,
    Map<String, String>? defaultHeaders,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? _defaultBaseUrl,
        _headers = Map<String, String>.from(defaultHeaders ?? {}),
        _client = client ?? http.Client();

  static const String _defaultBaseUrl = 'https://api.unsplash.com';

  final String _baseUrl;
  final Map<String, String> _headers;
  final http.Client _client;

  /// Default headers sent with every request. Add Authorization here (e.g. Unsplash Client-ID).
  Map<String, String> get headers => Map.unmodifiable(_headers);

  void setHeader(String key, String value) {
    _headers[key] = value;
  }

  void setAuthorization(String value) {
    _headers['Authorization'] = value;
  }

  /// GET request. [path] should start with /. [queryParams] are appended as query string.
  /// Returns [ApiResponse] with statusCode, body (raw string), and success flag.
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headersOverride,
  }) async {
    final uri = Uri.parse(_baseUrl + path).replace(queryParameters: queryParams);
    final requestHeaders = {..._headers, ...?headersOverride};

    try {
      final response = await _client.get(uri, headers: requestHeaders);
      final success = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        success: success,
      );
    } catch (e, stack) {
      return ApiResponse(
        statusCode: -1,
        body: e.toString(),
        success: false,
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// POST request. [body] can be Map (encoded as JSON) or String.
  Future<ApiResponse> post(
    String path, {
    Object? body,
    Map<String, String>? headersOverride,
  }) async {
    final uri = Uri.parse(_baseUrl + path);
    final requestHeaders = {..._headers, ...?headersOverride};
    final encodedBody = body is Map ? jsonEncode(body) : body?.toString();

    try {
      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );
      final success = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        success: success,
      );
    } catch (e, stack) {
      return ApiResponse(
        statusCode: -1,
        body: e.toString(),
        success: false,
        error: e,
        stackTrace: stack,
      );
    }
  }
}

/// Raw API response before parsing into models.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
    required this.success,
    this.error,
    this.stackTrace,
  });

  final int statusCode;
  final String body;
  final bool success;
  final Object? error;
  final StackTrace? stackTrace;

  /// Decode body as JSON. Returns null if body is empty or invalid.
  dynamic get json {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body) as dynamic;
    } catch (_) {
      return null;
    }
  }
}
