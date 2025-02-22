import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isMarked = false;

  // Sample attendance data for pie chart
  Map<String, double> attendanceData = {"Present": 85, "Absent": 15};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markAttendance() {
    setState(() {
      isMarked = true;
    });
    _controller.forward(from: 0.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance Marked Successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //Screen Background
          ScreensBackground(height: height, width: width),

          // Main Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.02),

                  // Date, Time and Location Card
                  OpaqueContainer(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Row
                        const Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Date :',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '16 Feb',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Time Row
                        const Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Time :',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '9:30 AM - 12:30 AM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Location Row
                        const Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Location :',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              'IT Seminar Hall',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Neumorphic Mark Attendance Button
                        Center(
                          child: GestureDetector(
                            onTap: !isMarked ? _markAttendance : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(255, 255, 255, 0.2),
                                    offset: Offset(-3, -3),
                                    blurRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    offset: Offset(3, 5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                isMarked ? 'Marked' : 'Mark Attendance',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Attendance Status Section
                  const Text(
                    'Attendance Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pie Chart
                  PieChart(
                    dataMap: attendanceData,
                    animationDuration: const Duration(milliseconds: 900),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3,
                    colorList: const [Color(0xFF661058), Color(0xFF2B8B7B)],
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendTextStyle: TextStyle(color: Colors.white),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: false,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true,
                      decimalPlaces: 1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Total Attendance :',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          '${attendanceData["Present"]?.toInt()} %',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
