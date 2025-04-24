import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/services/branch_service.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  _SchedulesScreenState createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  List<Schedule> schedules = [];
  List<Schedule> filteredSchedules = [];
  bool isLoading = true;
  String? userBranch;
  String errorMessage = '';
  List<String> allBranches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT','CSD', 'CSM','PHE','BME','AI & DS','CHEM','CSBS'];
  String selectedBranch = 'All';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    getUserBranch();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    isAdmin = prefs.getBool('isAdmin') ?? false;
  });

    _fetchSchedules(); 
  }

  Future<void> getUserBranch() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('studentEmail'); 

    if (email == null || email.isEmpty) {
      return;
    }

    final branch = await StudentService.getBranchByEmail(email);

    if (branch != null) {
      await prefs.setString('branch', branch);

      setState(() {
        userBranch = branch;
        selectedBranch = branch;
      });

    } else {
      setState(() {
        errorMessage = 'Branch not found for email: $email';
      });
    }
  } catch (e) {
    setState(() {
        errorMessage = 'Failed to fetch branch: $e';
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
      
      // Update the print statement
      print('Raw schedulesData received (all schedules): $schedulesData'); 

      // Add specific error handling for parsing
      try {
        final parsedSchedules = schedulesData.map((data) {
          // Add a try-catch within the map to pinpoint parsing errors
          try {
            return Schedule.fromJson(data as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing schedule item: $data');
            print('Parsing error: $e');
            // Re-throw or handle appropriately, maybe return a default/error Schedule object
            rethrow; 
          }
        }).toList();

        setState(() {
          if (isAdmin) {
            schedules = parsedSchedules;
          } else {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            schedules = parsedSchedules.where((schedule) {
              final scheduleDate = DateTime.tryParse(schedule.date);
              final isFutureOrToday = scheduleDate != null && (scheduleDate.isAfter(today) || scheduleDate.isAtSameMomentAs(today) && _isTimeAfterNow(schedule.time, now));
              final isBranchMatch = schedule.studentBranch.contains(userBranch ?? '');
              return isFutureOrToday && isBranchMatch;
            }).toList();
          }
          schedules.sort((a, b) {
            // Safely parse dates, handle potential FormatException
            try {
              // Ensure the date strings are in a valid format before parsing
              final dateA = DateTime.tryParse(a.date);
              final dateB = DateTime.tryParse(b.date);
              
              // If parsing fails for either date, handle appropriately (e.g., don't sort or place them at the end)
              if (dateA == null || dateB == null) {
                 print('Warning: Could not parse date for sorting: ${a.date} or ${b.date}');
                 return 0; // Maintain original order if parsing fails
              }
              return dateB.compareTo(dateA); // Newest first
            } catch (e) {
              // Catch any unexpected error during parsing/comparison
              print('Error during date sorting: $e');
              return 0; // Default sort order if parsing fails
            }
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
    if (selectedBranch == 'All') {
      filteredSchedules = List.from(schedules);
    } else {
      filteredSchedules = schedules
          .where((schedule) => schedule.studentBranch.contains(selectedBranch))
          .toList();
    }
  }

bool _isTimeAfterNow(String timeStr, DateTime now) {
  try {
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);

    return scheduleTime.isAfter(now);
  } catch (e) {
    print('Error parsing time: $timeStr');
    return false;
  }
}

  String _formatDate(String dateStr) { // Input should now be "YYYY-MM-DD"
    try {
      final date = DateTime.tryParse(dateStr); 
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date); 
      } else {
        return dateStr; 
      }
    } catch (e) {
      return dateStr; 
    }
  }

  String _formatTime(String timeStr) { // Input should now be "HH:mm"
    try {
      int hour = int.parse(timeStr.split(':')[0]);
      int minute = int.parse(timeStr.split(':')[1]);
      final time = TimeOfDay(hour: hour, minute: minute);

      // Format to AM/PM
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt); 

    } catch (e) {
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
      appBar: const CustomAppBar(),
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
                  Center(
                    child: Text(
                      'Your Schedules',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  if (isAdmin)
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
                              color: selectedBranch == 'All' ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                        ...allBranches.map((branch) => Padding(
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
                              color: selectedBranch == branch ? Colors.white : Colors.white70,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  if (isLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
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
                          'No schedules found for ${selectedBranch == 'All' ? 'any branch' : selectedBranch}.',
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
                          padding: EdgeInsets.symmetric(vertical: height * 0.01),
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
                                        Icon(Icons.calendar_today, color: Colors.orange, size: width * 0.04),
                                        SizedBox(width: width * 0.02),
                                        Text(
                                          _formatDate(schedule.date), // Use the formatter
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
                                        Icon(Icons.access_time, color: Colors.orange, size: width * 0.04),
                                        SizedBox(width: width * 0.02),
                                        Text(
                                          _formatTime(schedule.time), // Use the formatter
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
                                        Icon(Icons.school, color: Colors.orange, size: width * 0.04),
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