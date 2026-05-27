import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:classroom_app/features/auth/data/models/user_model.dart';

/// Remote data source with actual API implementation
abstract class AuthRemoteDataSource {
  Future<UserModel> registerWithEmail(String email);
  Future<Map<String, dynamic>> sendRegistrationOtp(String name, String email); // New method
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String baseUrl = 'https://ai-healthcare-ip89.onrender.com';
  final http.Client _client;

  AuthRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UserModel> registerWithEmail(String email) async {
    // TODO: Implement full registration after OTP verification
    throw UnimplementedError('registerWithEmail not implemented yet');
  }

  @override
  Future<Map<String, dynamic>> sendRegistrationOtp(String name, String email) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/register-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    // TODO: Apple Sign-In flow
    throw UnimplementedError('signInWithApple not implemented yet');
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    // TODO: Facebook Sign-In flow
    throw UnimplementedError('signInWithFacebook not implemented yet');
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // TODO: Google Sign-In flow
    throw UnimplementedError('signInWithGoogle not implemented yet');
  }
}