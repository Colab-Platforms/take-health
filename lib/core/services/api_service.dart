import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete,
}

class ApiService {
  ApiService._();

  static const String _baseUrl =
      'https://ai-healthcare-ip89.onrender.com/api';

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  static const Duration _timeout = Duration(seconds: 30);

  // =========================================================
  // LOCAL STORAGE
  // =========================================================

  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);

    await prefs.setString(
      _userKey,
      jsonEncode(user),
    );
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);

    await prefs.remove(_userKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      return jsonDecode(userString);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // =========================================================
  // RETRY LOGIC
  // =========================================================

  static Future<http.Response> _retryRequest(
      Future<http.Response> Function() request,
      ) async {
    int retry = 0;

    while (retry < 3) {
      final response = await request();

      if (response.statusCode != 503) {
        return response;
      }

      retry++;

      await Future.delayed(
        const Duration(seconds: 2),
      );
    }

    throw const HttpException(
      'Server unavailable',
    );
  }

  // =========================================================
  // CORE REQUEST HANDLER
  // =========================================================

  static Future<dynamic> _request({
    required HttpMethod method,
    required String path,
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$path',
      );

      final headers = <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (requireAuth) {
        final token = await getToken();

        if (token != null && token.isNotEmpty) {
          headers['Authorization'] =
          'Bearer $token';
        }
      }

      final encodedBody =
      body != null ? jsonEncode(body) : null;

      late http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await _retryRequest(
                () => http
                .get(
              uri,
              headers: headers,
            )
                .timeout(_timeout),
          );
          break;

        case HttpMethod.post:
          response = await _retryRequest(
                () => http
                .post(
              uri,
              headers: headers,
              body: encodedBody,
            )
                .timeout(_timeout),
          );
          break;

        case HttpMethod.put:
          response = await _retryRequest(
                () => http
                .put(
              uri,
              headers: headers,
              body: encodedBody,
            )
                .timeout(_timeout),
          );
          break;

        case HttpMethod.delete:
          response = await _retryRequest(
                () => http
                .delete(
              uri,
              headers: headers,
            )
                .timeout(_timeout),
          );
          break;
      }

      // ============================
      // 401 HANDLING
      // ============================

      if (response.statusCode == 401) {
        await clearAuthData();

        throw const HttpException(
          'Session expired. Please login again.',
        );
      }

      // ============================
      // SUCCESS
      // ============================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }

        return jsonDecode(response.body);
      }

      // ============================
      // ERROR PARSING
      // ============================

      String errorMessage = 'Request failed';

      try {
        final errorData = jsonDecode(response.body);

        errorMessage =
            errorData['message'] ??
                errorData['error'] ??
                errorData['detail'] ??
                errorMessage;
      } catch (_) {}

      throw HttpException(
        '$errorMessage (${response.statusCode})',
      );
    } on SocketException {
      throw const SocketException(
        'No internet connection.',
      );
    } on FormatException {
      throw const FormatException(
        'Invalid response format.',
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // AUTH APIs
  // =========================================================

  /// POST auth/register-otp
  static Future<Map<String, dynamic>>
  sendRegisterOtp({
    required String name,
    required String email,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/register-otp',
      body: {
        'name': name,
        'email': email,
      },
      requireAuth: false,
    );

    return response;
  }

  /// POST auth/register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otp,
    String role = 'user',
    Map<String, dynamic>? profile,
    Map<String, dynamic>? nutritionGoal,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'otp': otp,
        'role': role,
        'profile': profile ?? {},
        'nutritionGoal': nutritionGoal ?? {},
      },
      requireAuth: false,
    );

    if (response['token'] != null) {
      await saveAuthData(
        token: response['token'],
        user: response['user'] ?? {},
      );
    }

    return response;
  }

  /// POST auth/login
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final isEmail = identifier.contains('@');

    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/login',
      body: {
        isEmail ? 'email' : 'phone': identifier,
        'password': password,
      },
      requireAuth: false,
    );

    if (response['token'] != null) {
      await saveAuthData(
        token: response['token'],
        user: response['user'] ?? {},
      );
    }

    return response;
  }

  /// POST auth/logout
  static Future<void> logout() async {
    try {
      await _request(
        method: HttpMethod.post,
        path: 'auth/logout',
      );
    } finally {
      await clearAuthData();
    }
  }

  // =========================================================
  // PASSWORD RESET APIs
  // =========================================================

  /// POST auth/forgot-password
  static Future<Map<String, dynamic>>
  forgotPassword({
    required String email,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/forgot-password',
      body: {
        'email': email,
      },
      requireAuth: false,
    );

    return response;
  }

  /// POST auth/verify-reset-code
  static Future<Map<String, dynamic>>
  verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/verify-reset-code',
      body: {
        'email': email,
        'code': code,
      },
      requireAuth: false,
    );

    return response;
  }

  /// POST auth/reset-password
  static Future<Map<String, dynamic>>
  resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'auth/reset-password',
      body: {
        'email': email,
        'code': code,
        'password': password,
      },
      requireAuth: false,
    );

    return response;
  }

  // =========================================================
  // PROFILE APIs
  // =========================================================

  /// GET auth/profile
  static Future<Map<String, dynamic>>
  getProfile() async {
    final response = await _request(
      method: HttpMethod.get,
      path: 'auth/profile',
    );

    return response;
  }

  /// PUT auth/profile
  static Future<Map<String, dynamic>>
  updateProfile(
      Map<String, dynamic> data,
      ) async {
    final response = await _request(
      method: HttpMethod.put,
      path: 'auth/profile',
      body: data,
    );

    if (response['user'] != null) {
      final token = await getToken();

      if (token != null) {
        await saveAuthData(
          token: token,
          user: response['user'],
        );
      }
    }

    return response;
  }

  // =========================================================
  // CHAT API
  // =========================================================

  /// POST chat
  static Future<String> sendChatMessage({
    required String query,
    required List<Map<String, String>>
    conversationHistory,
    List<dynamic>? userReports,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'chat',
      requireAuth: true,
      body: {
        'query': query,
        'conversationHistory':
        conversationHistory,
        'userReports': userReports ?? [],
      },
    );

    if (response is Map<String, dynamic>) {
      final aiResponse =
          response['response'] ??
              response['message'] ??
              response['answer'];

      if (aiResponse != null) {
        return aiResponse.toString();
      }
    }

    throw const FormatException(
      'Invalid AI response.',
    );
  }
}