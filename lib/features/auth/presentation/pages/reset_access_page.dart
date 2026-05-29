import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:http/http.dart' as http;

import '../widgets/auth_app_bar.dart';

class ResetAccessPage extends StatefulWidget {
  const ResetAccessPage({super.key});

  @override
  State<ResetAccessPage> createState() => _ResetAccessPageState();
}

class _ResetAccessPageState extends State<ResetAccessPage> {
  final TextEditingController emailController =
  TextEditingController();

  bool isLoading = false;

  Future<void> forgotPasswordApi() async {
    final String email =
    emailController.text.trim();

    // EMAIL VALIDATION
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://ai-healthcare-ip89.onrender.com/api/auth/forgot-password',
        ),

        headers: {
          'Content-Type':
          'application/json',
          'Accept':
          'application/json',
        },

        body: jsonEncode({
          "email": email,
        }),
      );

      print(
        "STATUS CODE : ${response.statusCode}",
      );

      print(
        "RAW RESPONSE : ${response.body}",
      );

      // HANDLE HTML RESPONSE
      if (response.body.startsWith('<!DOCTYPE html>')) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Server is waking up. Please try again in few seconds.',
            ),
          ),
        );

        return;
      }

      dynamic data;

      try {
        data = jsonDecode(
          response.body,
        );
      } catch (e) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid server response',
            ),
          ),
        );

        return;
      }

      // SUCCESS
      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  'OTP sent successfully',
            ),
          ),
        );

        context.push(AppRoutes.forgetPasswordOtp, extra: email);

      } else {

        // ERROR RESPONSE
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  'Something went wrong',
            ),
          ),
        );
      }

    } catch (e) {

      print("ERROR : $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error : $e',
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const AuthAppBar(),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 32,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 50),

            // TITLE
            Text(
              'Reset Access',

              style:
              AppTextStyles.heading
                  .copyWith(
                fontSize: 28,
                color: Colors.black,
                fontWeight:
                FontWeight.w800,
                fontFamily:
                'SF Pro Display',
              ),
            ),

            const Text(
              'Step 1 of 3 • Email',

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.1,
                fontFamily: 'SF Pro Display',
              ),
            ),

            const SizedBox(height: 32),

            // EMAIL FIELD
            _buildField(
              controller:
              emailController,
              label: 'Email Address',
              hint: 'Email Address',
              icon:
              Icons.email_outlined,
              onChanged: (val) {},
            ),

            const SizedBox(height: 32),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF0D4D3B,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),

                onPressed: isLoading
                    ? null
                    : forgotPasswordApi,

                child: isLoading

                    ? const SizedBox(
                  height: 24,
                  width: 24,

                  child:
                  CircularProgressIndicator(
                    color:
                    Colors.white,
                    strokeWidth:
                    2.5,
                  ),
                )

                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [

                    Text(
                      'Send Code',

                      style:
                      TextStyle(
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight
                            .w600,
                        letterSpacing:
                        1.5,
                        fontFamily:
                        'SF Pro Display',
                      ),
                    ),

                    SizedBox(
                      width: 8,
                    ),

                    Icon(
                      Icons
                          .arrow_forward,
                      size: 20,
                    ),
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

  Widget _buildField({
    required TextEditingController
    controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String)
    onChanged,
  }) {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: const TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.8,
            fontFamily:
            'SF Pro Display',
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,

          onChanged: onChanged,

          keyboardType:
          TextInputType.emailAddress,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle:
            const TextStyle(
              color: Colors.black26,
              fontWeight:
              FontWeight.w500,
            ),

            prefixIcon: Icon(
              icon,
              color: Colors.grey
                  .withValues(
                alpha: 0.4,
              ),
              size: 22,
            ),

            filled: true,

            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),

              borderSide:
              const BorderSide(
                color:
                Colors.black12,
                width: 1.5,
              ),
            ),

            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),

              borderSide:
              const BorderSide(
                color:
                Colors.black12,
                width: 1.5,
              ),
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),

              borderSide:
              const BorderSide(
                color:
                Color(
                  0xFF0D4D3B,
                ),
                width: 1.5,
              ),
            ),

            contentPadding:
            const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}