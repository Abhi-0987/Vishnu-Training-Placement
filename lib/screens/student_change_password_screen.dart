import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:lottie/lottie.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final baseUrl = AppConstants.backendUrl;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  void _changePassword(String email) async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Password fields cannot be empty.");
      return;
    }

    if (!isValidPassword(newPassword)) {
      _showSnackBar(
        "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.",
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/api/student/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      _showSnackBar("Password changed successfully");

      // Redirect to login or home screen
      Navigator.pushReplacementNamed(context, AppRoutes.studentHomeScreen);
    } else {
      _showSnackBar("Error changing password");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String email = args["email"];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: height * 0.08,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vishnu',
                  style: TextStyle(
                    color: AppConstants.textWhite,
                    fontSize: width * 0.09,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Alata',
                  ),
                ),
                SizedBox(width: width * 0.02),
                Column(
                  children: [
                    Text(
                      'Training and',
                      style: TextStyle(
                        color: AppConstants.textWhite,
                        fontSize: width * 0.05,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Placements',
                      style: TextStyle(
                        color: AppConstants.textWhite,
                        fontSize: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
              ),
            ),
          ),

          // Top-left decorative circle
          Positioned(
            top: -height * 0.2,
            left: -width * 0.32,
            child: Container(
              width: width * 0.6,
              height: height * 0.3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(154, 164, 86, 22),
                    blurRadius: 130,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),

          // Bottom-right decorative circle
          Positioned(
            bottom: -height * 0.15,
            right: -width * 0.32,
            child: Container(
              width: width * 0.6,
              height: height * 0.3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(141, 102, 16, 88),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Glass Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, 0.05),
              ),
            ),
          ),
          _isLoading
              ? Center(
                child: Transform.scale(
                  scale: 1.5,
                  child: Lottie.asset(
                    'assets/loading.json',
                    frameRate: FrameRate(100),
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.17),

                    Text(
                      'Change your',
                      style: TextStyle(
                        color: AppConstants.textWhite,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Password',
                      style: TextStyle(
                        color: AppConstants.textWhite,
                        fontSize: width * 0.08,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Alata',
                      ),
                    ),
                    SizedBox(height: height * 0.05),

                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: width * 0.8,
                            child: Image.asset('assets/tlogo.png'),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: height * 0.03),
                            Align(
                              alignment: Alignment.center,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 15,
                                    sigmaY: 15,
                                  ),
                                  child: Container(
                                    height: height * 0.32,
                                    width: width * 0.96,
                                    padding: EdgeInsets.all(width * 0.05),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(30, 0, 0, 0),
                                      borderRadius: BorderRadius.circular(
                                        width * 0.04,
                                      ),
                                      border: Border.all(
                                        color: AppConstants.textWhite,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Password input
                                        TextField(
                                          controller: newPasswordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: AppConstants.textBlack,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible =
                                                      !_isPasswordVisible; // Toggle password visibility
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[400]
                                                ?.withAlpha(170),
                                            hintText: 'Enter password',
                                            hintStyle: TextStyle(
                                              color: AppConstants.textBlack,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppConstants.textBlack,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: height * 0.023,
                                                  horizontal: width * 0.01,
                                                ),
                                          ),
                                        ),
                                        // Password input
                                        TextField(
                                          controller: confirmPasswordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: AppConstants.textBlack,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible =
                                                      !_isPasswordVisible; // Toggle password visibility
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[400]
                                                ?.withAlpha(170),
                                            hintText: 'Confirm password',
                                            hintStyle: TextStyle(
                                              color: AppConstants.textBlack,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppConstants.textBlack,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: height * 0.023,
                                                  horizontal: width * 0.01,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(
                                            width * 0.006,
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black
                                                  .withAlpha(220),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.1,
                                                vertical: height * 0.013,
                                              ),
                                            ),
                                            onPressed:
                                                () => _changePassword(email),
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                color: AppConstants.textWhite,
                                                fontSize: width * 0.04,
                                                fontFamily: 'Alata',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.04),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Need help with login?',
                          style: TextStyle(
                            color: AppConstants.textWhite,
                            fontSize: width * 0.045,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          'Contact Administrator',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: width * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
