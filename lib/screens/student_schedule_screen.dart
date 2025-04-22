import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
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
    // Remove the userBranch check as we will fetch all schedules now
    // if (userBranch == null) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Fetch ALL schedules instead of just by user's branch
      final schedulesData = await ScheduleServices.getAllSchedules();

      // Update the print statement
      print('Raw schedulesData received (all schedules): $schedulesData');

      // Add specific error handling for parsing
      try {
        final parsedSchedules =
            schedulesData.map((data) {
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
          schedules = parsedSchedules;
          schedules.sort((a, b) {
            // Safely parse dates, handle potential FormatException
            try {
              // Ensure the date strings are in a valid format before parsing
              final dateA = DateTime.tryParse(a.date);
              final dateB = DateTime.tryParse(b.date);

              // If parsing fails for either date, handle appropriately (e.g., don't sort or place them at the end)
              if (dateA == null || dateB == null) {
                print(
                  'Warning: Could not parse date for sorting: ${a.date} or ${b.date}',
                );
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
        // Catch errors specifically from the mapping/parsing process
        setState(() {
          errorMessage = 'Failed to parse schedule data: $e';
          isLoading = false;
        });
      }
    } catch (e) {
      // Catch errors from the API call itself
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
      filteredSchedules =
          schedules
              .where(
                (schedule) => schedule.studentBranch.contains(selectedBranch),
              )
              .toList();
    }
  }

  String _formatDate(String dateStr) {
    // Input should now be "YYYY-MM-DD"
    try {
      final date = DateTime.tryParse(dateStr); // tryParse handles "YYYY-MM-DD"
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date); // e.g., "Jan 20, 2024"
      } else {
        print('Warning: Could not parse date for formatting: $dateStr');
        return dateStr; // Fallback
      }
    } catch (e) {
      print('Error formatting date $dateStr: $e');
      return dateStr; // Fallback
    }
  }

  String _formatTime(String timeStr) {
    // Input should now be "HH:mm"
    try {
      // Parse the "HH:mm" string
      int hour = int.parse(timeStr.split(':')[0]);
      int minute = int.parse(timeStr.split(':')[1]);
      final time = TimeOfDay(hour: hour, minute: minute);

      // Format to AM/PM
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt); // e.g., "9:30 AM"
    } catch (e) {
      print('Error formatting time $timeStr: $e');
      return timeStr; // Fallback
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
                        color: AppConstants.textWhite,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        child: CircularProgressIndicator(
                          color: AppConstants.backgroundColor,
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
                                backgroundColor: AppConstants.backgroundColor,
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
                            color: AppConstants.textWhite,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchSchedules,
                        color: AppConstants.backgroundColor,
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
                                        color: AppConstants.textWhite,
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
                                          _formatDate(
                                            schedule.date,
                                          ), // Use the formatter
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
                                          _formatTime(
                                            schedule.time,
                                          ), // Use the formatter
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
