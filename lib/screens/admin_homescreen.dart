import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/services/admin_service.dart';
import 'package:vishnu_training_and_placements/services/coordinator_service.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? userRole;
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'admin';

    setState(() {
      userRole = role;
    });

    _fetchUserName(role);
  }

  Future<void> _fetchUserName(String role) async {
    final prefs = await SharedPreferences.getInstance();
    //used hivebox
    final box = Hive.box('infoBox');
    if (role == 'coordinator') {
      final email = prefs.getString('coordinatorEmail');

      if (email == null) {
        setState(() {
          userName = "Coordinator";
          isLoading = false;
        });
        return;
      }

      final coordinatorData = box.get('coordinatorDetails');

      if (coordinatorData != null && coordinatorData['name'] != null) {
        // Load from Hive
        setState(() {
          userName = coordinatorData['name'];
          isLoading = false;
        });
      } else {
        // Fallback to API
        final data = await CoordinatorService.getCoordinatorDetails(email);
        if (data != null && data['name'] != null) {
          box.put('coordinatorDetails', data);
          setState(() {
            userName = data['name'];
            isLoading = false;
          });
        } else {
          setState(() {
            userName = "Coordinator";
            isLoading = false;
          });
        }
      }
    } else {
      final email = prefs.getString('adminEmail');

      if (email == null) {
        setState(() {
          userName = "Admin";
          isLoading = false;
        });
        return;
      }

      final adminData = box.get('adminDetails');

      if (adminData != null && adminData['name'] != null) {
        // Load from Hive
        setState(() {
          userName = adminData['name'];
          isLoading = false;
        });
      } else {
        // Fallback to API
        final data = await AdminService.getAdminDetails(email);
        if (data != null && data['name'] != null) {
          box.put('adminDetails', data);
          setState(() {
            userName = data['name'];
            isLoading = false;
          });
        } else {
          setState(() {
            userName = "Admin";
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;
    return Scaffold(
      backgroundColor: AppConstants.textBlack,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          ScreensBackground(height: height, width: width),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Hello..!!',
                            style: TextStyle(
                              fontSize: 28,
                              color: AppConstants.textWhite,
                              fontFamily: 'Alata',
                            ),
                          ),
                          isLoading
                              ? const CircularProgressIndicator(
                                color: AppConstants.textWhite,
                              )
                              : Text(
                                userName ??
                                    (userRole == 'coordinator'
                                        ? 'Coordinator'
                                        : 'Admin'),
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: AppConstants.textWhite,
                                  fontFamily: 'Alata',
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: CustomCard(
                            text: 'Schedule a\n Class',
                            style: TextStyle(
                              fontSize: 300,
                              fontFamily: 'Alata',
                            ),
                            image: 'assets/schedule.png',
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.eventVenue);
                          },
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          child: CustomCard(
                            text: 'Your Schedules',
                            style: TextStyle(fontSize: 70, fontFamily: 'Alata'),
                            image: 'assets/your-schedules.png',
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.allSchedulesScreen,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        if (userRole != 'coordinator')
                          GestureDetector(
                            child: CustomCard(
                              text: 'Message Sending',
                              style: TextStyle(
                                fontSize: 70,
                                fontFamily: 'Alata',
                              ),
                              image: 'assets/send.png',
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.markAttendanceAdmin,
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String text;
  final String? image;

  const CustomCard({
    super.key,
    required this.text,
    this.image,
    required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.19,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: AppConstants.textWhite,
                    fontSize: 25,
                  ),
                ),
                if (image != null)
                  Image.asset(
                    image!,
                    height: screenHeight * 0.20,
                    width: screenWidth * 0.20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
