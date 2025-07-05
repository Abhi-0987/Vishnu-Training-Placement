import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/screens/splash_screen.dart';
import 'package:vishnu_training_and_placements/services/student_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/services/Schedule_service.dart';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  const StudentProfileScreen({super.key,required this.schedule});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String? studentName;
  String? studentRollNo;
  String? studentBranch;
  String? studentEmail;
  String? studentYear;
  bool isLoading = true;
  String? errorMessage;
  int presentPercentage = 0;
  int absentPercentage = 0;
  int totalSessions = 0;
  int presentCount = 0;
  // String longestStreak = '1 day';

  @override
 void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  await _loadStudentData();
  await _fetchAttendanceStats();
}

  Future<void> _loadStudentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('studentEmail');

      if (email == null || email.isEmpty) {
        throw Exception('Email not found in shared preferences');
      }
      final box = Hive.box('infoBox');
      final studentData = box.get('studentDetails');
      if (studentData != null && studentData['email'] == email) {
        // Load from Hive cache
        setState(() {
          studentName = studentData['name'];
          studentRollNo = studentData['email'].split('@')[0];
          studentYear = studentData['year'];
          studentBranch = studentData['branch'];
          studentEmail = studentData['email'];
          isLoading = false;
        });
      } else {
        // Fallback  to API
        final response = await StudentService.getStudentDetails(email);

        if (response == null) {
          throw Exception('No response from backend');
        }

        // Save in Hive for future use
        box.put('studentDetails', response);

        setState(() {
          studentName = response['name'];
          studentRollNo = response['email'].split('@')[0];
          studentYear = response['year'];
          studentBranch = response['branch'];
          studentEmail = response['email'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load profile: ${e.toString()}';
        isLoading = false;
      });
      _showErrorSnackbar(e.toString());
    }
  }

Future<void> _fetchAttendanceStats() async {
  final email = studentEmail;
  if (email == null) return;

  final result = await ScheduleServices.getStudentOverallAttendance(email);
  if (result['success']) {
    final data = result['data'];
    setState(() {
      totalSessions = data['totalSessions'] ?? 0;
      int present = data['presentCount'] ?? 0;
      int absent = data['absentCount'] ?? 0;
      presentCount = data['presentCount'] ?? 0;

      presentPercentage = totalSessions > 0 ? ((present / totalSessions) * 100).round() : 0;
      absentPercentage = totalSessions > 0 ? ((absent / totalSessions) * 100).round() : 0;
    });
  } else {
    _showErrorSnackbar(result['message'] ?? 'Failed to load attendance stats');
  }
}


  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    await _loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return PopScope(
      onPopInvokedWithResult:
          (didPop, result) => Navigator.pushReplacementNamed(
            context,
            AppRoutes.studentHomeScreen,
          ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(isProfileScreen: true),
        backgroundColor: AppConstants.textBlack,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _buildMainContent(width, height),
        ),
      ),
    );
  }

  Widget _buildMainContent(double width, double height) {
    return Stack(
      children: [
        ScreensBackground(height: height, width: width),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage != null)
          Center(
            child: Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: AppConstants.textWhite,
                      fontSize: width * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    _buildStatisticsSection(width, height),
                    SizedBox(height: height * 0.03),
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
                            final box = Hive.box('infoBox');
                            if (!mounted) return;
                            await prefs.clear();
                            await box.clear();
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
                              horizontal: width * 0.18,
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

                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(double width, double height) {
    return OpaqueContainer(
      width: width,
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Row(
          children: [
            CircleAvatar(
              radius: width * 0.10,
              backgroundColor: Colors.grey[800],
              child: Icon(
                Icons.person,
                size: width * 0.12,
                color: Colors.white,
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileText(studentName ?? 'N/A', width),
                  _buildProfileText(studentRollNo ?? 'N/A', width),
                  _buildProfileText(studentYear ?? 'N/A', width),
                  _buildProfileText(studentBranch ?? 'N/A', width),
                  if (studentEmail != null)
                    _buildProfileText(studentEmail!, width),
                ],
              ),
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

  Widget _buildStatisticsSection(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statistics",
          style: TextStyle(
            fontSize: width * 0.07,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alata',
            color: AppConstants.textWhite,
          ),
        ),
        SizedBox(height: height * 0.02),
        Center(child: _buildPieChart(width, height)),
        SizedBox(height: height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(
              AppConstants.piechartcolor2,
              "Present ($presentPercentage%)",
            ),
            SizedBox(width: width * 0.04),
            _buildLegend(
              AppConstants.piechartcolor1,
              "Absent ($absentPercentage%)",
            ),
          ],
        ),
        SizedBox(height: height * 0.03),
        Row(
          children: [
            _buildInfoCard(
              "Total Sessions",
              "$totalSessions",
              AppConstants.textWhite,
              width,
              height,
            ),
            SizedBox(width: width * 0.03),
            _buildInfoCard(
              "Sessions Attended",
  presentCount.toString(), 
  AppConstants.textWhite,
  width,
  height,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(double width, double height) {
    return SizedBox(
      height: height * 0.25,
      width: width * 0.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: width * 0.08,
          sections: [
            PieChartSectionData(
              value: presentPercentage.toDouble(),
              color: AppConstants.piechartcolor2,
              title: '$presentPercentage%',
              radius: width * 0.15,
              titleStyle: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alata',
                color: AppConstants.textWhite,
              ),
            ),
            PieChartSectionData(
              value: absentPercentage.toDouble(),
              color: AppConstants.piechartcolor1,
              title: '$absentPercentage%',
              radius: width * 0.15,
              titleStyle: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alata',
                color: AppConstants.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(66, 66, 66, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Alata',
              color: AppConstants.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    Color color,
    double width,
    double height,
  ) {
    return Expanded(
      child: OpaqueContainer(
        width: width,
        child: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width * 0.1,
                height: 4,
                color: Colors.yellow,
                margin: EdgeInsets.only(bottom: height * 0.01),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.032,
                  fontFamily: 'Alata',
                  color: Colors.yellow[100],
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                value,
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alata',
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



