import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

import '../widgets/auth_app_bar.dart';
import '../bloc/auth_bloc.dart';

class ForgetPasswordOtp extends StatefulWidget {
  final String email; // 👈 Accept email from previous screen

  const ForgetPasswordOtp({
    super.key,
    required this.email,
  });

  @override
  State<ForgetPasswordOtp> createState() => _ForgetPasswordOtpState();
}

class _ForgetPasswordOtpState extends State<ForgetPasswordOtp> {
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  String? _otpError;

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
                    'Verify OTP',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Text(
                    'Enter the 4-digit code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            Center(
              child: Column(
                children: [
                  Text(
                    'Verification Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121A2C),
                      letterSpacing: 0.8,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Pinput(
                controller: _otpController,
                length: 4,
                keyboardType: TextInputType.number,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(
                      color: const Color(0xFF0D4D3B),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (_otpError != null) {
                    setState(() {
                      _otpError = null;
                    });
                  }
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

            const SizedBox(height: 24),

            Center(
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
                      text: 'Resend code',
                      style: TextStyle(
                        color: const Color(0xFF0D4D3B),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
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

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    // OTP Validation
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _otpError = "OTP is required";
      });
      return;
    }

    if (_otpController.text.trim().length != 4) {
      setState(() {
        _otpError = "OTP must be 4 digits";
      });
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      final otp = _otpController.text.trim();

      // 👇 API Call
      final response = await http.post(
        Uri.parse('https://ai-healthcare-ip89.onrender.com/api/auth/verify-reset-code'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email, // 👈 email passed from previous screen
          'code': otp,
        }),
      );

      if (!mounted) return;

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Verified Successfully"),
            backgroundColor: Color(0xFF0D4D3B),
          ),
        );

        // Navigate to reset password page
        context.push(AppRoutes.secureAccount, extra: {
          'email': widget.email,
          'code': otp,
        });
      } else {
        // Show error from API response if available
        final message = responseBody['message'] ?? 'Invalid OTP. Please try again.';
        setState(() {
          _otpError = message;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Please check your connection."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}