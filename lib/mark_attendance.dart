import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

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
  Map<String, double> attendanceData = {
    "Present": 85,
    "Absent": 15,
  };

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
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: Stack(
        children: [
          // Background with elliptical containers
          Positioned(
            top: -100,
            right: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(102, 16, 88, 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(102, 16, 88, 0.4),
                    blurRadius: 130,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(43, 139, 123, 0.01),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(43, 139, 123, 0.3),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Glass Layer - Positioned above ellipses but below text, buttons, etc.
          Positioned.fill(
            child: BackdropFilter(
              filter:
              ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Glass blur effect
              child: Container(
                color: const Color.fromRGBO(
                    255, 255, 255, 0.05), // Slight tint for glass
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logo and title
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 50),
                      const SizedBox(width: 60),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vishnu',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Alata'),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Column(
                            children: [
                              Text(
                                'Training and',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Alata'),
                              ),
                              Text(
                                'Placements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Date, Time and Location Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                        const SizedBox(height: 15),

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
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
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
