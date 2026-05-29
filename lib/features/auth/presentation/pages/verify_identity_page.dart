import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/auth_app_bar.dart';
import '../bloc/auth_bloc.dart';

class VerifyIdentityPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const VerifyIdentityPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends State<VerifyIdentityPage> {
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _otpError;
  int _resendTimer = 0;
  String? _resendMessage;
  bool _showResendSuccess = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _updateTimer();
  }

  void _updateTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _updateTimer();
          }
        });
      }
    });
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait ${_resendTimer} seconds before resending'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isResending = true;
      _resendMessage = null;
      _showResendSuccess = false;
    });

    try {
      // Use the correct endpoint for sending OTP (same as registration)
      final response = await http.post(
        Uri.parse('https://ai-healthcare-ip89.onrender.com/api/auth/register-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": widget.name,
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully resent
        setState(() {
          _showResendSuccess = true;
          _resendMessage = "Verification code resent successfully!";
          _resendTimer = 30; // Reset timer
        });

        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification code resent successfully! Please check your email."),
            backgroundColor: Color(0xFF0D4D3B),
            duration: Duration(seconds: 3),
          ),
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showResendSuccess = false;
              _resendMessage = null;
            });
          }
        });
      } else {
        setState(() {
          _resendMessage = data["message"] ?? "Failed to resend code";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Failed to resend code"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _resendMessage = "Error: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_otpController.text.trim().isEmpty) {
      setState(() => _otpError = "OTP is required");
      return;
    }

    if (_otpController.text.trim().length != 6) {
      setState(() => _otpError = "OTP must be 6 digits");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(_otpController.text.trim())) {
      setState(() => _otpError = "OTP must contain only numbers");
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://ai-healthcare-ip89.onrender.com/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": widget.name,
          "email": widget.email,
          "otp": _otpController.text.trim(),
          "phone": widget.phone,
          "password": widget.password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("jwt_token", data["token"] ?? "");

        await prefs.setString("user_data", jsonEncode({
          "_id":   data["_id"]   ?? data["user"]?["_id"]   ?? "",
          "name":  data["name"]  ?? data["user"]?["name"]  ?? widget.name,
          "email": data["email"] ?? data["user"]?["email"] ?? widget.email,
          "phone": data["phone"] ?? data["user"]?["phone"] ?? widget.phone,
        }));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Verified Successfully"),
            backgroundColor: Color(0xFF0D4D3B),
          ),
        );

        context.pushReplacement(AppRoutes.setupProfile);
      } else {
        if (!mounted) return;

        // Check if the error is about expired/invalid code
        String errorMessage = data["message"] ?? "Verification failed";
        if (errorMessage.toLowerCase().contains("expired") ||
            errorMessage.toLowerCase().contains("invalid")) {
          setState(() {
            _otpError = "Code expired or invalid. Please request a new code.";
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0D4D3B),
        fontFamily: 'SF Pro Display',
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AuthAppBar(
        onBackPressed: () {
          context.read<AuthBloc>().add(const AuthReset());
          context.pop();
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Text(
                    'Verify Identity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                widget.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),

            const SizedBox(height: 48),

            const Center(
              child: Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121A2C),
                  letterSpacing: 0.8,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Pinput(
                controller: _otpController,
                length: 6,
                keyboardType: TextInputType.number,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFF0D4D3B), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  if (_otpError != null) setState(() => _otpError = null);
                },
              ),
            ),

            if (_otpError != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _otpError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            if (_showResendSuccess) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _resendMessage ?? "Code resent successfully!",
                  style: const TextStyle(
                    color: Color(0xFF0D4D3B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: _isResending ? null : _resendCode,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                    children: [
                      const TextSpan(text: "Didn't receive code? "),
                      TextSpan(
                        text: _isResending
                            ? "Sending..."
                            : (_resendTimer > 0
                            ? "Resend code in ${_resendTimer}s"
                            : "Resend code"),
                        style: TextStyle(
                          color: (_isResending || _resendTimer > 0)
                              ? Colors.grey.shade400
                              : const Color(0xFF0D4D3B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D4D3B),
                  disabledBackgroundColor: const Color(0xFF0D4D3B).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}