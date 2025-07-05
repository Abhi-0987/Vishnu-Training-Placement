import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StudentSchedulesScreen extends StatefulWidget {
  const StudentSchedulesScreen({super.key, this.enabled = false});
  final bool enabled;

  @override
  State<StudentSchedulesScreen> createState() => _StudentSchedulesScreenState();
}

class _StudentSchedulesScreenState extends State<StudentSchedulesScreen> {
  List<Schedule> schedules = [];
  List<Schedule> filteredSchedules = [];
  bool isLoading = true;
  String? userBranch;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getUserBranch();
  }

  Future<void> getUserBranch() async {
    try {
      // final prefs =  await SharedPreferences.getInstance();
      // final branch = prefs.getString('studentbranch');
      final box = Hive.box('infoBox');
      final studentDetails = box.get('studentDetails');
      final branch = studentDetails?['branch'];
      print('Retrieved branch from SharedPreferences: $branch');

      if (branch == null || branch.isEmpty) {
        setState(() {
          errorMessage = 'Branch not found';
          isLoading = false;
        });
        return;
      }

      setState(() {
        userBranch = branch;
      });

      _fetchSchedules();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch branch: $e';
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final parsedSchedules =
          schedulesData.map((data) {
            return Schedule.fromJson(data as Map<String, dynamic>);
          }).toList();

      final filtered =
          parsedSchedules.where((schedule) {
            final scheduleDate = DateTime.tryParse(schedule.date);
            final isFutureOrToday =
                scheduleDate != null &&
                (scheduleDate.isAfter(today) ||
                    (scheduleDate.isAtSameMomentAs(today) &&
                        _isTimeAfterNow(schedule.time, now)));
            final isBranchMatch = schedule.studentBranch.contains(
              userBranch ?? '',
            );
            final isEnabled = (schedule.mark == true);
            return widget.enabled
                ? isFutureOrToday && isBranchMatch && isEnabled
                : isFutureOrToday && isBranchMatch;
          }).toList();

      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a.date);
        final dateB = DateTime.tryParse(b.date);
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      setState(() {
        schedules = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load schedules: $e';
        isLoading = false;
      });
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
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      return date != null ? DateFormat('MMM dd, yyyy').format(date) : dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

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
                  if (isLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.primaryColor,
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
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _fetchSchedules,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (schedules.isEmpty)
                    Column(
                      children: [
                        SizedBox(height: height * 0.3),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.enabled
                                ? 'There is no Attendance to mark'
                                : 'No schedules found for your branch.',
                            style: TextStyle(
                              color: AppConstants.textWhite,
                              fontSize: width * 0.04,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchSchedules,
                        color: AppConstants.primaryColor,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.01,
                          ),
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
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
                                        if (schedule.mark)
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          MarkAttendancePage(
                                                            schedule: schedule,
                                                          ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppConstants.primaryColor,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.03,
                                                vertical: height * 0.005,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              'Mark Attendance',
                                              style: TextStyle(
                                                color: AppConstants.textWhite,
                                                fontSize: width * 0.035,
                                              ),
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
