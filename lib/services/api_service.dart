import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  static const int _timeoutSeconds = 30;

  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = true,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse<T>(
        success: false,
        message: 'Server error. Please try again later.',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse<T>(
        success: false,
        message: 'Server error. Please try again later.',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse<T>(
        success: false,
        message: 'Server error. Please try again later.',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  static Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T? Function(dynamic)? fromJson,
  ) {
    try {
      // Handle empty response
      if (response.body.isEmpty) {
        return ApiResponse<T>(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode >= 200 && response.statusCode < 300
              ? 'Success'
              : 'Empty response from server',
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return ApiResponse<T>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      // Handle array response (some endpoints return plain arrays)
      if (data is List) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          T? parsedData;
          if (fromJson != null) {
            try {
              parsedData = fromJson(data);
            } catch (e) {
              // Parsing failed silently
            }
          }
          return ApiResponse<T>(
            success: true,
            message: 'Success',
            data: parsedData,
          );
        } else {
          return ApiResponse<T>(
            success: false,
            message: 'Request failed',
          );
        }
      }

      // Handle object response
      if (data is Map<String, dynamic>) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse<T>.fromJson(data, fromJson);
        } else {
          // Error response
          String errorMessage = 'Request failed';
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (data['error'] != null) {
            errorMessage = data['error'].toString();
          }

          List<String>? errors;
          if (data['errors'] != null) {
            if (data['errors'] is Map) {
              errors = [];
              (data['errors'] as Map).forEach((key, value) {
                if (value is List) {
                  errors!.addAll(value.map((e) => e.toString()));
                } else {
                  errors!.add(value.toString());
                }
              });
            } else if (data['errors'] is List) {
              errors = List<String>.from(data['errors'].map((e) => e.toString()));
            }
          }

          return ApiResponse<T>(
            success: false,
            message: errorMessage,
            errors: errors,
          );
        }
      }

      return ApiResponse<T>(
        success: false,
        message: 'Unexpected response format',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Failed to process response: ${e.toString()}',
      );
    }
  }
}
