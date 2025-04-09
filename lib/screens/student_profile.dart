import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/roots/app_roots.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

      return PopScope(
      canPop: false,
        onPopInvoked: (didPop) {
        if (didPop) return;
          Navigator.pushReplacementNamed(context, AppRoutes.studentHomeScreen);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(isProfileScreen: true),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            ScreensBackground(height: height, width: width),
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
                    Text(
                      "Statistics",
                      style: TextStyle(
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Center(child: buildPieChart(width, height)),

                    Row(
                      children: [
                        SizedBox(width: width * 0.27),
                        _buildLegend(const Color(0xFF18B0C1), "Present"),
                        SizedBox(width: width * 0.04),
                        _buildLegend(const Color(0xFFB45AA8), "Absent"),
                      ],
                    ),

                    SizedBox(height: height * 0.03),
                    Row(
                      children: [
                        _buildInfoCard(
                          "Total Sessions",
                          "8",
                          Colors.white,
                          width,
                          height,
                        ),
                        SizedBox(width: width * 0.04),
                        _buildInfoCard(
                          "Longest Streak",
                          "1 day",
                          Colors.white,
                          width,
                          height,
                        ),
                      ],
                    ),
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
    return OpaqueContainer(
      width: width,
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
              children: [
                Text(
                  "N.V Dheeraj",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: Colors.white,
                  ),
                ),
                Text(
                  "22211A1277",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Information Technology",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Section B",
                  style: TextStyle(
                    fontSize: width * 0.035,
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

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Alata',
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildPieChart(double width, double height) {
    return SizedBox(
      height: height * 0.30,
      width: width * 0.50,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: width * 0.10,
          sections: [
            PieChartSectionData(
              value: 60,
              color: const Color(0xFF18B0C1),
              title: '60%',
              radius: width * 0.20,
              titleStyle: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alata',
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 40,
              color: const Color(0xFFB45AA8),
              title: '40%',
              radius: width * 0.20,
              titleStyle: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alata',
                color: Colors.white,
              ),
            ),
          ],
        ),
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
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width * 0.10,
                height: 4,
                color: Colors.yellow,
                margin: EdgeInsets.only(bottom: height * 0.01),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontFamily: 'Alata',
                  color: Colors.yellow[50],
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                value,
                style: TextStyle(
                  fontSize: width * 0.06,
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