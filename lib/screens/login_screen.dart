import 'dart:convert';
import 'dart:ui';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vishnu_training_and_placements/services/admin_service.dart';
import 'package:vishnu_training_and_placements/services/auth_service.dart';
import 'package:vishnu_training_and_placements/services/coordinator_service.dart';
import 'package:vishnu_training_and_placements/services/student_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Show loading indicator

  // Future<String?> getAndroidDeviceId() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   return androidInfo.id; // Unique ID (but may change on factory reset )
  // }

  Future<void> login() async {
    final password = passwordController.text.trim();
    final email = emailController.text.trim();
    // final deviceId = await getAndroidDeviceId();

    if (email.isEmpty || password.isEmpty) {
      showError("Email and password cannot be empty.");
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    try {
      final response = await AuthService().login(
        email,
        password,
        // deviceId!,
        widget.role,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (data["role"] == "Student") {
          prefs.setBool('isLoggedIn', true);
          prefs.setString('role', 'student');
          prefs.setString('token', data['accessToken']);
          prefs.setString('refreshToken', data['refreshToken']);
          prefs.setString('studentEmail', email);
          final studentResponse = await StudentService.getStudentDetails(email);
          if (studentResponse != null) {
            final box = Hive.box('infoBox');
            box.put('studentDetails', studentResponse); // entire object
          }
          if (mounted) {
            if (data["login"] == false) {
              Navigator.pushNamed(
                context,
                AppRoutes.changePasswordScreen,
                arguments: {"email": email},
              );
            } else {
              Navigator.pushNamed(context, AppRoutes.studentHomeScreen);
            }
          } // Navigate on success
        } else if (data["role"] == "Coordinator") {
          prefs.setBool('isLoggedIn', true);
          prefs.setString('role', 'coordinator');
          prefs.setString('token', data['accessToken']);
          prefs.setString('refreshToken', data['refreshToken']);
          prefs.setString('coordinatorEmail', email);
          final coordinatorResponse =
              await CoordinatorService.getCoordinatorDetails(email);
          if (coordinatorResponse != null) {
            final box = Hive.box('infoBox');
            box.put('coordinatorDetails', coordinatorResponse);
          }
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.adminHomeScreen);
          }
        } else if (data["role"] == "Admin") {
          prefs.setBool('isLoggedIn', true);
          prefs.setString('role', 'admin');
          prefs.setString('token', data['accessToken']);
          prefs.setString('refreshToken', data['refreshToken']);
          prefs.setString('adminEmail', email);
          final adminResponse = await AdminService.getAdminDetails(email);
          if (adminResponse != null) {
            final box = Hive.box('infoBox');
            box.put('adminDetails', adminResponse);
          }
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.adminHomeScreen);
          }
          // else {
          //   Navigator.pushNamed(context, AppRoutes.adminHomeScreen);
          // } // Navigate on success
        } else {
          showError(jsonDecode(response.body)['error']);
        }
      } else {
        showError(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showError("Something went wrong. Try again later.");
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
                        color: AppConstants.textWhite,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Authentication',
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
                                    height: height * 0.36,
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
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[400]
                                                ?.withAlpha(170),
                                            hintText: 'Enter your email',
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
                                                  horizontal: width * 0.03,
                                                ),
                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                              40,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller: passwordController,
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
                                                      !_isPasswordVisible;
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
                                                  horizontal: width * 0.03,
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
                                                AppConstants.gradient_1,
                                                AppConstants.gradient_2,
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(
                                            width * 0.008,
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
                                                horizontal: width * 0.12,
                                                vertical: height * 0.016,
                                              ),
                                            ),
                                            onPressed:
                                                _isLoading ? null : login,
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                color: AppConstants.textWhite,
                                                fontSize: width * 0.045,
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
