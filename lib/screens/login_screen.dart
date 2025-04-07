import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/roots/app_roots.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class StudentLoginScreen extends StatefulWidget {
  final bool isAdmin;
  const StudentLoginScreen({super.key, required this.isAdmin});

  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Show loading indicator

  // Function to send login request to Spring Boot
  Future<void> login() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final url = Uri.parse(
      'http://localhost:8080/api/auth/${widget.isAdmin ? 'admin/login' : 'student/login'}',
    ); // Spring Boot URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      }),
    );

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      if (data["role"] == "Student") {
        prefs.setBool('isLoggedIn', true);
        prefs.setString('role', 'student');
        prefs.setString('token', data['accessToken']);
        prefs.setString('refreshToken', data['refreshToken']);

        Navigator.pushNamed(
          context,
          AppRoutes.studentHomeScreen,
        ); // Navigate on success
      } else if (data["role"] == "Admin") {
        prefs.setBool('isLoggedIn', true);
        prefs.setString('role', 'admin');
        prefs.setString('token', data['accessToken']);
        prefs.setString('refreshToken', data['refreshToken']);

        Navigator.pushNamed(
          context,
          AppRoutes.event_venue,
        ); // Navigate on success
      } else {
        showError("Invalid Credentials");
      }
    } else {
      showError("Server Error. Try again.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

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
                    color: Colors.white,
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
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Placements',
                      style: TextStyle(
                        color: Colors.white,
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
                      'Please Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Authentication',
                      style: TextStyle(
                        color: Colors.white,
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
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Email input with fixed domain inside the text box
                                        TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[400]
                                                ?.withAlpha(170),
                                            hintText: 'Enter your email',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: height * 0.023,
                                                  horizontal: width * 0.01,
                                                ),
                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                              40,
                                            ), // Limit input length
                                          ],
                                        ),

                                        // Password input
                                        TextField(
                                          controller: passwordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: Colors.black,
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
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: Colors.black,
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
                                                Colors.orangeAccent,
                                                Colors.pinkAccent,
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
                                                _isLoading ? null : login,
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
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
                            color: Colors.white,
                            fontSize: width * 0.045,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          'Contact us',
                          style: TextStyle(
                            color: Colors.purple,
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
