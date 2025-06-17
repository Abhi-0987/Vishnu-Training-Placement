import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:vishnu_training_and_placements/services/attendance_service.dart';
import 'package:vishnu_training_and_placements/services/venue_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key, this.schedule});
  final Schedule? schedule;

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double targetLatitude = 0;
  double targetLongitude = 0;
  final double radiusInMeters = 25;
  bool isMarked = false;
  bool _isLoading = false;

  // Sample attendance data for pie chart
  Map<String, double> attendanceData = {"Present": 85, "Absent": 15};

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> _fetchCoordinates() async {
    final venue = widget.schedule!.location;
    final roomNo = widget.schedule!.roomNo;

    final coordinates = await VenueService().fetchCoordinates(venue, roomNo);

    targetLatitude = coordinates['latitude']!;
    targetLongitude = coordinates['longitude']!;
    print("$targetLatitude, $targetLongitude");
  }

  Future<String> _markAttendance() async {
    setState(() {
      isMarked = true;
    });
    final message = AttendanceService().markAttendance(
      widget.schedule!.date,
      widget.schedule!.time,
    );
    _controller.forward(from: 0.0);
    return message;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return false;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location services are disabled. Please enable the services.',
          ),
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return false;
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  /// Fetches current location and validates distance before submitting attendance
  Future<void> submitAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );

      if (distance <= radiusInMeters) {
        final message = await _markAttendance();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                message == 'Attendance marked as present successfully.'
                    ? Colors.green
                    : Colors.red,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You are not in the designated area to submit attendance.\n'
              'Your location: (${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)})',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      backgroundColor: AppConstants.textBlack,
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
                        Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Date :',
                                style: TextStyle(
                                  color: AppConstants.textWhite,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              widget.schedule!.date,
                              style: TextStyle(
                                color: AppConstants.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Time Row
                        Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Time :',
                                style: TextStyle(
                                  color: AppConstants.textWhite,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              widget.schedule!.time,
                              style: TextStyle(
                                color: AppConstants.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Location Row
                        Row(
                          children: [
                            SizedBox(
                              width: 100, // Fixed width for labels
                              child: Text(
                                'Location :',
                                style: TextStyle(
                                  color: AppConstants.textWhite,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              "${widget.schedule!.location} - ${widget.schedule!.roomNo}",
                              style: TextStyle(
                                color: AppConstants.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Neumorphic Mark Attendance Button
                        _isLoading
                            ? CircularProgressIndicator(
                              color: AppConstants.primaryColor,
                            )
                            : Center(
                              child: GestureDetector(
                                onTap: !isMarked ? submitAttendance : null,
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
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.2,
                                        ),
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
                                      color: AppConstants.textWhite,
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
                      color: AppConstants.textWhite,
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
                    colorList: const [
                      AppConstants.piechartcolor1,
                      AppConstants.piechartcolor2,
                    ],
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendTextStyle: TextStyle(color: AppConstants.textWhite),
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
                            color: AppConstants.textWhite,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${attendanceData["Present"]?.toInt()} %',
                          style: const TextStyle(
                            color: AppConstants.textWhite,
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
