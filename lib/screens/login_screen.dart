import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vishnu_training_and_placements/roots/app_roots.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input
      if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both email and password'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/users/login'), // Changed from localhost to 10.0.2.2 for Android emulator
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Login successful
        final token = response.body;
        // TODO: Store token securely using flutter_secure_storage
        Navigator.pushReplacementNamed(context, AppRoutes.studentHomeScreen);
      } else {
        // Login failed
        String errorMessage;
        try {
          final responseData = json.decode(response.body);
          errorMessage = responseData is String ? responseData : 'Invalid email or password';
        } catch (e) {
          errorMessage = 'Invalid email or password';
        }
        
        if (!mounted) return;
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
        const SnackBar(
          content: Text('Connection error. Please check your internet connection and try again.'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
            SingleChildScrollView(
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
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
                                      TextField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[400]?.withAlpha(
                                            170,
                                          ),
                                          hintText: 'Enter your email',
                                          hintStyle: TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
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
      
                                      TextField(
                                        controller: _passwordController,
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
                                          fillColor: Colors.grey[400]?.withAlpha(
                                            170,
                                          ),
                                          hintText: 'Enter password',
                                          hintStyle: TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: height * 0.023,
                                            horizontal: width * 0.01,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.2,
                                            vertical: height * 0.02,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? CircularProgressIndicator(color: Colors.white)
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: width * 0.045,
                                                  color: Colors.white,
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
      ),
    );
  }
}