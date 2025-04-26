import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.studentHomeScreen);
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(isProfileScreen: true),
        backgroundColor: AppConstants.textBlack,
        body: SingleChildScrollView(
          child: Stack(
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
                            color: AppConstants.textWhite,
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
                          color: AppConstants.textWhite,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Center(child: buildPieChart(width, height)),

                      Row(
                        children: [
                          SizedBox(width: width * 0.27),
                          _buildLegend(AppConstants.piechartcolor2, "Present"),
                          SizedBox(width: width * 0.04),
                          _buildLegend(AppConstants.piechartcolor1, "Absent"),
                        ],
                      ),

                      SizedBox(height: height * 0.03),
                      Row(
                        children: [
                          _buildInfoCard(
                            "Total Sessions",
                            "8",
                            AppConstants.textWhite,
                            width,
                            height,
                          ),
                          SizedBox(width: width * 0.04),
                          _buildInfoCard(
                            "Longest Streak",
                            "1 day",
                            AppConstants.textWhite,
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
                    color: AppConstants.textWhite,
                  ),
                ),
                Text(
                  "22211A1277",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: AppConstants.textWhite,
                  ),
                ),
                Text(
                  "Information Technology",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: AppConstants.textWhite,
                  ),
                ),
                Text(
                  "Section B",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontFamily: 'Alata',
                    color: AppConstants.textWhite,
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
            color: AppConstants.textWhite,
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
              color: AppConstants.piechartcolor2,
              title: '60%',
              radius: width * 0.20,
              titleStyle: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alata',
                color: AppConstants.textWhite,
              ),
            ),
            PieChartSectionData(
              value: 40,
              color: AppConstants.piechartcolor1,
              title: '40%',
              radius: width * 0.20,
              titleStyle: TextStyle(
                fontSize: width * 0.04,
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
