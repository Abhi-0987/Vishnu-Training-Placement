import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/screens/student_schedule_screen.dart';
import 'package:vishnu_training_and_placements/services/student_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';

//home screen
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String? studentName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('studentEmail');

    if (email == null) {
      setState(() {
        studentName = "Student";
        isLoading = false;
      });
      return;
    }

    final box = Hive.box('infoBox'); // Use your unified box
    final studentData = box.get('studentDetails');

    if (studentData != null && studentData['name'] != null) {
      // Load from Hive
      setState(() {
        studentName = studentData['name'];
        isLoading = false;
      });
    } else {
      // Fallback: Fetch from server and store in Hive
      final response = await StudentService.getStudentDetails(email);
      if (response != null && response['name'] != null) {
        box.put('studentDetails', response);
        setState(() {
          studentName = response['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          studentName = "Student";
          isLoading = false;
        });
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
                              studentName ?? 'Student',
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround, // Center the cards
                    children: [
                      GestureDetector(
                        child: CustomCard(
                          text: 'Mark Your\nAttendance',
                          style: TextStyle(fontSize: 300, fontFamily: 'Alata'),
                          image: 'assets/attendance.png',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      StudentSchedulesScreen(enabled: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        child: CustomCard(
                          text: 'Your Schedules',
                          style: TextStyle(fontSize: 70, fontFamily: 'Alata'),
                          image: 'assets/calendar.png',
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.studentScheduleScreen,
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
            height: MediaQuery.of(context).size.height * 0.22,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ), // Optional border
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
                    height: screenHeight * 0.30,
                    width: screenWidth * 0.3,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
