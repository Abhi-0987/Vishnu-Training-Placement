import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StudentSchedulesScreen extends StatefulWidget {
  const StudentSchedulesScreen({super.key});

  @override
  _StudentSchedulesScreenState createState() => _StudentSchedulesScreenState();
}

class _StudentSchedulesScreenState extends State<StudentSchedulesScreen> {
  List<Schedule> schedules = [];
  List<Schedule> filteredSchedules = [];
  List<Schedule> currentSchedules = []; // For current and future schedules
  List<Schedule> pastSchedules = []; // For past schedules
  bool isLoading = true;
  String? userBranch;
  String errorMessage = '';
  List<String> allBranches = [
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT',
    'CSD',
    'CSM',
    'PHE',
    'BME',
    'AI & DS',
    'CHEM',
    'CSBS',
  ];
  String selectedBranch = 'All';
  bool showPastSchedules =
      false; // Flag to toggle between current and past schedules

  @override
  void initState() {
    super.initState();
    _getUserBranch();
  }

  Future<void> _getUserBranch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userBranch =
            prefs.getString('branch') ?? 'CSE'; // Default to CSE if not found
        selectedBranch =
            userBranch!; // Set selected branch to user's branch initially
      });
      _fetchSchedules();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get user branch: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSchedules() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final schedulesData = await ScheduleServices.getAllSchedules();

      print('Raw schedulesData received (all schedules): $schedulesData');

      try {
        final parsedSchedules =
            schedulesData.map((data) {
              try {
                return Schedule.fromJson(data as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing schedule item: $data');
                print('Parsing error: $e');
                rethrow;
              }
            }).toList();

        setState(() {
          schedules = parsedSchedules;

          // Separate current/future schedules from past schedules
          final now = DateTime.now();
          currentSchedules =
              schedules.where((schedule) {
                final scheduleDate = DateTime.tryParse(schedule.date);
                if (scheduleDate == null) return false;
                return scheduleDate.isAfter(
                  now.subtract(const Duration(days: 1)),
                ); // Include today
              }).toList();

          pastSchedules =
              schedules.where((schedule) {
                final scheduleDate = DateTime.tryParse(schedule.date);
                if (scheduleDate == null) return false;
                return scheduleDate.isBefore(
                  now.subtract(const Duration(days: 1)),
                ); // Before today
              }).toList();

          // Sort both lists by date (newest first)
          currentSchedules.sort((a, b) {
            final dateA = DateTime.tryParse(a.date) ?? DateTime.now();
            final dateB = DateTime.tryParse(b.date) ?? DateTime.now();
            return dateA.compareTo(dateB); // Upcoming first
          });

          pastSchedules.sort((a, b) {
            final dateA = DateTime.tryParse(a.date) ?? DateTime.now();
            final dateB = DateTime.tryParse(b.date) ?? DateTime.now();
            return dateB.compareTo(dateA); // Most recent past first
          });

          _filterSchedules();
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to parse schedule data: $e';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load schedules: $e';
        isLoading = false;
      });
    }
  }

  void _filterSchedules() {
    // First determine which list to use based on showPastSchedules flag
    List<Schedule> sourceList =
        showPastSchedules ? pastSchedules : currentSchedules;

    // Then filter by branch
    if (selectedBranch == 'All') {
      filteredSchedules = List.from(sourceList);
    } else {
      filteredSchedules =
          sourceList
              .where(
                (schedule) => schedule.studentBranch.contains(selectedBranch),
              )
              .toList();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date);
      } else {
        print('Warning: Could not parse date for formatting: $dateStr');
        return dateStr;
      }
    } catch (e) {
      print('Error formatting date $dateStr: $e');
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      int hour = int.parse(timeStr.split(':')[0]);
      int minute = int.parse(timeStr.split(':')[1]);
      final time = TimeOfDay(hour: hour, minute: minute);

      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      print('Error formatting time $timeStr: $e');
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          ScreensBackground(height: height, width: width),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          showPastSchedules
                              ? 'Past Schedules'
                              : 'Your Schedules',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showPastSchedules = !showPastSchedules;
                            _filterSchedules();
                          });
                        },
                        icon: Icon(
                          showPastSchedules
                              ? Icons.calendar_today
                              : Icons.history,
                          color: Colors.white,
                          size: width * 0.04,
                        ),
                        label: Text(
                          showPastSchedules ? 'Current' : 'History',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.02),

                  // Branch selection chips
                  SizedBox(
                    height: height * 0.05,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('All'),
                            selected: selectedBranch == 'All',
                            onSelected: (selected) {
                              setState(() {
                                selectedBranch = 'All';
                                _filterSchedules();
                              });
                            },
                            backgroundColor: Colors.purple.withOpacity(0.3),
                            selectedColor: Colors.purple,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  selectedBranch == 'All'
                                      ? Colors.white
                                      : Colors.white70,
                            ),
                          ),
                        ),
                        ...allBranches.map(
                          (branch) => Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(branch),
                              selected: selectedBranch == branch,
                              onSelected: (selected) {
                                setState(() {
                                  selectedBranch = branch;
                                  _filterSchedules();
                                });
                              },
                              backgroundColor: Colors.purple.withOpacity(0.3),
                              selectedColor: Colors.purple,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color:
                                    selectedBranch == branch
                                        ? Colors.white
                                        : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.02),
                  if (isLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.purple),
                      ),
                    )
                  else if (errorMessage.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _fetchSchedules,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredSchedules.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          showPastSchedules
                              ? 'No past schedules found'
                              : 'No upcoming schedules found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchSchedules,
                        color: Colors.purple,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.01,
                          ),
                          itemCount: filteredSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = filteredSchedules[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: height * 0.02),
                              child: OpaqueContainer(
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${schedule.location} - Room ${schedule.roomNo}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.01),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.orange,
                                          size: width * 0.04,
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Text(
                                          _formatDate(schedule.date),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: width * 0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.orange,
                                          size: width * 0.04,
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Text(
                                          _formatTime(schedule.time),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: width * 0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: Colors.orange,
                                          size: width * 0.04,
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Expanded(
                                          child: Text(
                                            'For: ${schedule.studentBranch}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: width * 0.035,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
}
