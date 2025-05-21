import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/screens/splash_screen.dart';
import 'package:vishnu_training_and_placements/services/admin_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
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
  final TextEditingController studentEmailController = TextEditingController();
  String baseUrl = AppConstants.backendUrl;
  String? adminEmail;
  String? adminName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('adminEmail');

    if (email == null) return;

    final data = await AdminService.getAdminDetails(email);

    if (data != null) {
      setState(() {
        adminEmail = data['email'];
        adminName = data['name'];
      });
    } else {
      _showSnackBar("Failed to load admin details");
    }
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  void _resetStudentPassword() async {
    final email = studentEmailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Email field cannot be empty.");
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/student/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      _showSnackBar("Student password reset successfully.");
      studentEmailController.clear();
    } else {
      _showSnackBar("Failed to reset student password.");
    }
  }

  void _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Password fields cannot be empty.");
      return;
    }

    if (!isValidPassword(newPassword)) {
      _showSnackBar("Password must be at least 8 characters and include uppercase, lowercase, number, and special character.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }
    
    final success = await AdminService.changePassword(adminEmail!, newPassword);

    if (success) {
      _showSnackBar("Password changed successfully");
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      _showSnackBar("Error changing password");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showStudentPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Student Password"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: studentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter student email',
                    filled: true,
                    fillColor: Colors.grey[300],
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
                    _resetStudentPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPasswordChangeDialog() {
    bool localPasswordVisible = false;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Admin Password"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: newPasswordController,
                      obscureText: !localPasswordVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            localPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              localPasswordVisible = !localPasswordVisible;
                            });
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
                      obscureText: !localPasswordVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            localPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              localPasswordVisible = !localPasswordVisible;
                            });
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
                        backgroundColor: AppConstants.primaryColor,
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
                          color: AppConstants.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(isProfileScreen: true),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
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
                        color: AppConstants.textWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildProfileCard(width, height),
                  SizedBox(height: height * 0.02),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppConstants.gradient_2,
                            AppConstants.gradient_1,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(width * 0.001),
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _showPasswordChangeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withAlpha(220),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.18,
                            vertical: height * 0.013,
                          ),
                        ),
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppConstants.textWhite,
                            fontSize: width * 0.04,
                            fontFamily: 'Alata',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppConstants.gradient_2,
                            AppConstants.gradient_1,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(width * 0.001),
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _showStudentPasswordResetDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withAlpha(220),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.115,
                            vertical: height * 0.013,
                          ),
                        ),
                        child: Text(
                          'Change Student Password',
                          style: TextStyle(
                            color: AppConstants.textWhite,
                            fontSize: width * 0.04,
                            fontFamily: 'Alata',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppConstants.gradient_2,
                            AppConstants.gradient_1,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(width * 0.001),
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ),
                            (routes) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withAlpha(220),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.28,
                            vertical: height * 0.013,
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppConstants.textWhite,
                            fontSize: width * 0.04,
                            fontFamily: 'Alata',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                size: width * 0.12,
                color: AppConstants.textWhite,
              ),
            ),
            SizedBox(width: width * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileText(adminEmail ?? '', width),
                _buildProfileText(adminName ?? '', width),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileText(String text, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: width * 0.035,
          fontFamily: 'Alata',
          color: AppConstants.textWhite,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
