import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  static const String _baseUrl  = 'https://ai-healthcare-ip89.onrender.com/api';
  static const String _tokenKey = 'jwt_token';
  static const String _userKey  = 'user_data';
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
    await prefs.setString(_userKey, jsonEncode(user));
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
    final String? userString = prefs.getString(_userKey);
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
      if (response.statusCode != 503) return response;
      retry++;
      await Future.delayed(const Duration(seconds: 2));
    }
    throw const HttpException('Server unavailable');
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
      final uri = Uri.parse('$_baseUrl/$path');

      final headers = <String, String>{
        'accept'      : 'application/json',
        'Content-Type': 'application/json',
      };

      if (requireAuth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final encodedBody = body != null ? jsonEncode(body) : null;

      // ── REQUEST LOG ──────────────────────────────────────────────────
      debugPrint('');
      debugPrint('┌─────────────── API REQUEST ───────────────────────────');
      debugPrint('│ ${method.name.toUpperCase()}  $uri');
      debugPrint('│ Headers:');
      headers.forEach((k, v) {
        final display = k == 'Authorization'
            ? 'Bearer ...${v.length > 17 ? v.substring(v.length - 10) : '***'}'
            : v;
        debugPrint('│   $k: $display');
      });
      if (encodedBody != null) {
        debugPrint('│ Body:');
        try {
          const encoder = JsonEncoder.withIndent('│   ');
          debugPrint(encoder.convert(jsonDecode(encodedBody))
              .split('\n')
              .map((l) => '│   $l')
              .join('\n'));
        } catch (_) {
          debugPrint('│   $encodedBody');
        }
      } else {
        debugPrint('│ Body: (none)');
      }
      debugPrint('└───────────────────────────────────────────────────────');
      debugPrint('');
      // ────────────────────────────────────────────────────────────────

      late http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await _retryRequest(
                () => http.get(uri, headers: headers).timeout(_timeout),
          );
          break;
        case HttpMethod.post:
          response = await _retryRequest(
                () => http.post(uri, headers: headers, body: encodedBody).timeout(_timeout),
          );
          break;
        case HttpMethod.put:
          response = await _retryRequest(
                () => http.put(uri, headers: headers, body: encodedBody).timeout(_timeout),
          );
          break;
        case HttpMethod.delete:
          response = await _retryRequest(
                () => http.delete(uri, headers: headers).timeout(_timeout),
          );
          break;
      }

      // ── RESPONSE LOG ─────────────────────────────────────────────────
      debugPrint('');
      debugPrint('┌─────────────── API RESPONSE ──────────────────────────');
      debugPrint('│ Status : ${response.statusCode}');
      debugPrint('│ Body:');
      try {
        const encoder = JsonEncoder.withIndent('│   ');
        debugPrint(encoder.convert(jsonDecode(response.body))
            .split('\n')
            .map((l) => '│   $l')
            .join('\n'));
      } catch (_) {
        debugPrint('│   ${response.body}');
      }
      debugPrint('└───────────────────────────────────────────────────────');
      debugPrint('');
      // ────────────────────────────────────────────────────────────────

      // 401 — token expired / missing
      if (response.statusCode == 401) {
        await clearAuthData();
        throw const HttpException('Session expired. Please login again.');
      }

      // Success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      // Error parsing
      String errorMessage = 'Request failed';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ??
                errorData['error']   ??
                errorData['detail']  ??
                errorMessage;
      } catch (_) {}

      throw HttpException('$errorMessage (${response.statusCode})');

    } on SocketException {
      throw const SocketException('No internet connection.');
    } on FormatException {
      throw const FormatException('Invalid response format.');
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // AUTH APIs
  // =========================================================

  /// POST auth/register-otp
  static Future<Map<String, dynamic>> sendRegisterOtp({
    required String name,
    required String email,
  }) async {
    return await _request(
      method: HttpMethod.post,
      path: 'auth/register-otp',
      body: {'name': name, 'email': email},
      requireAuth: false,
    );
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
        'name'         : name,
        'email'        : email,
        'phone'        : phone,
        'password'     : password,
        'otp'          : otp,
        'role'         : role,
        'profile'      : profile       ?? {},
        'nutritionGoal': nutritionGoal ?? {},
      },
      requireAuth: false,
    );
    if (response['token'] != null) {
      await saveAuthData(token: response['token'], user: response['user'] ?? {});
    }
    return response;
  }

  /// POST auth/login
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final isEmail  = identifier.contains('@');
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
      await saveAuthData(token: response['token'], user: response['user'] ?? {});
    }
    return response;
  }

  /// POST auth/logout
  static Future<void> logout() async {
    try {
      await _request(method: HttpMethod.post, path: 'auth/logout');
    } finally {
      await clearAuthData();
    }
  }

  // =========================================================
  // PASSWORD RESET APIs
  // =========================================================

  /// POST auth/forgot-password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await _request(
      method: HttpMethod.post,
      path: 'auth/forgot-password',
      body: {'email': email},
      requireAuth: false,
    );
  }

  /// POST auth/verify-reset-code
  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return await _request(
      method: HttpMethod.post,
      path: 'auth/verify-reset-code',
      body: {'email': email, 'code': code},
      requireAuth: false,
    );
  }

  /// POST auth/reset-password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    return await _request(
      method: HttpMethod.post,
      path: 'auth/reset-password',
      body: {'email': email, 'code': code, 'password': password},
      requireAuth: false,
    );
  }

  // =========================================================
  // PROFILE APIs
  // =========================================================

  /// GET auth/profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await _request(method: HttpMethod.get, path: 'auth/profile');
  }

  /// PUT auth/profile
  static Future<Map<String, dynamic>> updateProfile(
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
        await saveAuthData(token: token, user: response['user']);
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
    required List<Map<String, String>> conversationHistory,
    List<dynamic>? userReports,
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'chat',
      requireAuth: true,
      body: {
        'query'              : query,
        'conversationHistory': conversationHistory,
        'userReports'        : userReports ?? [],
      },
    );
    if (response is Map<String, dynamic>) {
      final aiResponse =
          response['response'] ?? response['message'] ?? response['answer'];
      if (aiResponse != null) return aiResponse.toString();
    }
    throw const FormatException('Invalid AI response.');
  }

  // =========================================================
  // DIET PLAN APIs
  // =========================================================

  /// POST diet-recommendations/diet-plan/generate
  ///
  /// Call when the user taps "GENERATE MY PERSONALIZED PLAN" or "Different Food".
  /// [dietaryPreference] e.g. "vegetarian" | "non-vegetarian" | "vegan"
  /// [allergies]         list of allergy strings, pass [] if none
  /// [fitnessGoals]      list of goal strings, pass [] if none
  static Future<Map<String, dynamic>> generateDietPlan({
    String       dietaryPreference = 'vegetarian',
    List<String> allergies         = const [],
    List<String> fitnessGoals      = const [],
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'diet-recommendations/diet-plan/generate',
      requireAuth: true,
      body: {
        'dietaryPreference': dietaryPreference,
        'allergies'        : allergies,
        'fitnessGoals'     : fitnessGoals,
      },
    );
    return response ?? {};
  }

  /// GET diet-recommendations/diet-plan/active
  ///
  /// Cache-busting timestamp ensures a fresh response every call.
  static Future<Map<String, dynamic>> getActiveDietPlan() async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final response = await _request(
      method: HttpMethod.get,
      path: 'diet-recommendations/diet-plan/active?t=$ts',
      requireAuth: true,
    );
    return response ?? {};
  }

  /// GET diet-recommendations/diet-plan/history
  static Future<List<dynamic>> getDietPlanHistory() async {
    final response = await _request(
      method: HttpMethod.get,
      path: 'diet-recommendations/diet-plan/history',
      requireAuth: true,
    );
    if (response is List) return response;
    if (response is Map) {
      return (response['history'] ??
          response['data']    ??
          response['plans']   ??
          response['results'] ??
          []) as List<dynamic>;
    }
    return [];
  }

  // =========================================================
  // FOOD PREFERENCES API
  // =========================================================

  /// POST users/food-preferences
  ///
  /// [mealPreferences] keys: breakfast, lunch, snacks, dinner
  /// [preferredFoods]  → General tab items
  /// [foodsToAvoid]    → pass [] if no UI field yet
  /// [dietaryRestrictions] → pass [] if no UI field yet
  static Future<Map<String, dynamic>> saveFoodPreferences({
    required List<String> preferredFoods,
    required Map<String, List<String>> mealPreferences,
    List<String> foodsToAvoid        = const [],
    List<String> dietaryRestrictions = const [],
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'users/food-preferences',
      requireAuth: true,
      body: {
        'preferredFoods'      : preferredFoods,
        'foodsToAvoid'        : foodsToAvoid,
        'dietaryRestrictions' : dietaryRestrictions,
        'mealPreferences'     : mealPreferences,
        'lastUpdated'         : DateTime.now().toUtc().toIso8601String(),
      },
    );
    return response ?? {};
  }

  // =========================================================
  // NUTRITION / MEAL LOGGING API
  // =========================================================

  /// POST nutrition/log-meal
  static Future<Map<String, dynamic>> logMeal({
    required String mealType,
    required List<Map<String, dynamic>> foodItems,
    String?  imageUrl,
    String?  notes,
    DateTime? timestamp,
    int?     healthScore,
    int?     healthScore10,
    List<Map<String, dynamic>>? micronutrients,
    List<Map<String, dynamic>>? enhancementTips,
    String?  healthBenefitsSummary,
    List<String>? warnings,
    List<Map<String, dynamic>>? alternatives,
    String   source = 'manual',
  }) async {
    final response = await _request(
      method: HttpMethod.post,
      path: 'nutrition/log-meal',
      requireAuth: true,
      body: {
        'mealType'             : mealType,
        'foodItems'            : foodItems,
        'imageUrl'             : imageUrl  ?? '',
        'notes'                : notes     ?? '',
        'timestamp'            : (timestamp ?? DateTime.now()).toIso8601String(),
        'healthScore'          : healthScore   ?? 0,
        'healthScore10'        : healthScore10 ?? 0,
        'micronutrients'       : micronutrients    ?? [],
        'enhancementTips'      : enhancementTips   ?? [],
        'healthBenefitsSummary': healthBenefitsSummary ?? '',
        'warnings'             : warnings    ?? [],
        'alternatives'         : alternatives ?? [],
        'source'               : source,
      },
    );
    return response ?? {};
  }

  /// Converts a MealOption object into the foodItems format expected by logMeal.
  static Map<String, dynamic> convertMealOptionToApiFormat(
      dynamic mealOption,
      String  mealType,
      ) {
    return {
      'name'       : mealOption.name,
      'description': mealOption.ingredients,
      'quantity'   : '1 serving',
      'nutrition'  : {
        'calories': mealOption.kcal,
        'protein' : 0,
        'carbs'   : 0,
        'fats'    : 0,
        'fiber'   : 0,
        'sugar'   : 0,
        'sodium'  : 0,
        'vitamins': {
          'vitaminA' : 0,
          'vitaminC' : 0,
          'vitaminD' : 0,
          'vitaminB12': 0,
          'iron'     : 0,
          'calcium'  : 0,
        },
      },
    };
  }
}