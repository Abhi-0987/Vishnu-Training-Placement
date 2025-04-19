import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? adminEmail;

  @override
  void initState() {
    super.initState();
    loadEmail();
  }

  Future<void> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = prefs.getString('adminEmail');
    });
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  void _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

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
      Uri.parse('http://localhost:8080/api/auth/admin/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': adminEmail, 'newPassword': newPassword}),
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      _showSnackBar("Password changed successfully");
      Navigator.pop(context); // Go back to AdminProfile or previous screen
    } else {
      _showSnackBar("Error changing password");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Admin Password"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: newPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: 'Enter new password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: 'Confirm new password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _changePassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Change Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, AppRoutes.studentHomeScreen);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(isProfileScreen: true),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ScreensBackground effect
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
                ),
              ),
            ),
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
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: const Color.fromRGBO(255, 255, 255, 0.05),
                ),
              ),
            ),

            // Foreground
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alata',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _buildProfileCard(width, height),
                    SizedBox(height: height * 0.02),
                    Center(
                      child: ElevatedButton(
                        onPressed: _showPasswordChangeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(double width, double height) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Row(
          children: [
            CircleAvatar(
              radius: width * 0.10,
              backgroundImage: const AssetImage('assets/profile.png'),
            ),
            SizedBox(width: width * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "admin@bvrit.ac.in",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Alata',
                    color: Colors.white,
                  ),
                ),
                Text(
                  "admin",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Alata',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
