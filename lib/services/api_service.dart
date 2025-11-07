import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Timeout duration for requests
  static const Duration _timeout = Duration(seconds: 30);

  // Get the base URL (useful for debugging)
  String get baseUrl => _baseUrl;

  //get authorization headers
  Future<Map<String, String>> _getHeaders({
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // add authorization token if required
    if (requiresAuth) {
      try {
        final token = await _auth.currentUser?.getIdToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          throw Exception('No authentication token available');
        }
      } catch (e) {
        throw Exception('Failed to get authentication token: $e');
      }
    }

    // add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  //build full URL from endpoint
  String _buildUrl(String endpoint) {
    // Remove leading slash if present
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    return '$_baseUrl/$endpoint';
  }

  //log request details (for debugging)
  void _logRequest(String method, String url, {Map<String, dynamic>? body}) {
    print('---------------------------------------');
    print('$method Request');
    print('URL: $url');
    if (body != null) {
      print('Body: ${jsonEncode(body)}');
    }
    print('---------------------------------------');
  }

  // Log response details (for debugging)
  void _logResponse(http.Response response) {
    print('---------------------------------------');
    print('Response');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    print('---------------------------------------');
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    _logResponse(response);

    // Success responses (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse response',
          statusCode: response.statusCode,
        );
      }
    }

    // Error responses
    String errorMessage = 'Request failed';

    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['error'] ??
          errorBody['message'] ??
          'Unknown error occurred';
    } catch (e) {
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Request failed with status ${response.statusCode}';
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }

  // Handle exceptions
  Exception _handleException(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is SocketException) {
      return ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    }

    if (error is http.ClientException) {
      return ApiException(
        message: 'Connection failed. Please try again.',
        statusCode: 0,
      );
    }

    if (error is FormatException) {
      return ApiException(
        message: 'Invalid response format from server.',
        statusCode: 0,
      );
    }

    return ApiException(
      message: 'An unexpected error occurred: ${error.toString()}',
      statusCode: 0,
    );
  }

  // Perform GET request
  Future<dynamic> get(
      String endpoint, {
        bool requiresAuth = false,
        Map<String, String>? additionalHeaders,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      _logRequest('GET', url);

      final response = await http
          .get(
        Uri.parse(url),
        headers: headers,
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Perform POST request
  Future<dynamic> post(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requiresAuth = false,
        Map<String, String>? additionalHeaders,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      _logRequest('POST', url, body: body);

      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Perform PUT request
  Future<dynamic> put(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requiresAuth = false,
        Map<String, String>? additionalHeaders,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      _logRequest('PUT', url, body: body);

      final response = await http
          .put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Perform PATCH request
  Future<dynamic> patch(
      String endpoint, {
        required Map<String, dynamic> body,
        bool requiresAuth = false,
        Map<String, String>? additionalHeaders,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      _logRequest('PATCH', url, body: body);

      final response = await http
          .patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Perform DELETE request
  Future<dynamic> delete(
      String endpoint, {
        bool requiresAuth = false,
        Map<String, String>? additionalHeaders,
        Map<String, dynamic>? body,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      _logRequest('DELETE', url, body: body);

      final response = await http
          .delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Perform multipart request for file uploads
  Future<dynamic> uploadFile(
      String endpoint, {
        required String filePath,
        required String fileField,
        Map<String, String>? additionalFields,
        bool requiresAuth = false,
      }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // remove Content-Type as multipart will set it automatically
      headers.remove('Content-Type');

      print('---------------------------------------');
      print('MULTIPART Request');
      print('URL: $url');
      print('File: $filePath');
      print('---------------------------------------');

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      // Add file
      final file = await http.MultipartFile.fromPath(fileField, filePath);
      request.files.add(file);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  //check if the server is reachable
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse(_buildUrl('/health')))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //get current user's ID token
  Future<String?> getAuthToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  //refresh auth token
  Future<String?> refreshAuthToken() async {
    try {
      return await _auth.currentUser?.getIdToken(true); // force refresh
    } catch (e) {
      print('Error refreshing auth token: $e');
      return null;
    }
  }
}

//custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => message;

  //check if error is due to authentication
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  //check if error is due to not found
  bool get isNotFound => statusCode == 404;

  //check if error is due to validation
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  //check if error is due to server
  bool get isServerError => statusCode >= 500;

  //check if error is due to network
  bool get isNetworkError => statusCode == 0;

  //get user-friendly error message
  String get userFriendlyMessage {
    if (isNetworkError) {
      return 'No internet connection. Please check your network.';
    }

    if (isAuthError) {
      return 'Session expired. Please login again.';
    }

    if (isNotFound) {
      return 'The requested resource was not found.';
    }

    if (isServerError) {
      return 'Server error. Please try again later.';
    }

    return message;
  }
}

class ApiServiceSingleton {
  static final ApiServiceSingleton _instance = ApiServiceSingleton._internal();
  late final ApiService _apiService;

  factory ApiServiceSingleton() {
    return _instance;
  }

  ApiServiceSingleton._internal() {
    _apiService = ApiService();
  }

  static ApiService get instance => _instance._apiService;
}
