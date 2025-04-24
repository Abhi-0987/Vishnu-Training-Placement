import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/screens/schedule_details_screen.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';

class AllSchedulesScreen extends StatefulWidget {
  const AllSchedulesScreen({super.key});

  @override
  State<AllSchedulesScreen> createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  List<Schedule> schedules = [];
  List<Schedule> filteredSchedules = [];
  bool isLoading = true;
  String errorMessage = '';
  List<String> allBranches = [
    'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT',
    'CSD', 'CSM', 'PHE', 'BME', 'AI & DS', 'CHEM', 'CSBS'
  ];
  String selectedBranch = 'All';

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final schedulesData = await ScheduleServices.getAllSchedules();

      final parsedSchedules = (schedulesData).map((data) {
        try {
          return Schedule.fromJson(data as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing schedule: $e');
          rethrow;
        }
      }).toList();

      parsedSchedules.sort((a, b) {
        final dateA = DateTime.tryParse(a.date);
        final dateB = DateTime.tryParse(b.date);
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      setState(() {
        schedules = parsedSchedules;
        _filterSchedules();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load schedules: $e';
        isLoading = false;
      });
    }
  }

  void _filterSchedules() {
    setState(() {
      if (selectedBranch == 'All') {
        filteredSchedules = List.from(schedules);
      } else {
        filteredSchedules = schedules
            .where((schedule) => schedule.studentBranch.contains(selectedBranch))
            .toList();
      }
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      return date != null ? DateFormat('MMM dd, yyyy').format(date) : dateStr;
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      if (timeStr.isEmpty || !timeStr.contains(':')) return timeStr;
      int hour = int.parse(timeStr.split(':')[0]);
      int minute = int.parse(timeStr.split(':')[1]);
      final time = TimeOfDay(hour: hour, minute: minute);
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      print('Error formatting time: $e');
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showProfileIcon: true),
      body: Stack(
        children: [
          ScreensBackground(height: height, width: width),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Schedules',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap on a schedule to view details',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Branch Chips
                SizedBox(
                  height: height * 0.05,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: selectedBranch == 'All',
                          onSelected: (selected) {
                            selectedBranch = 'All';
                            _filterSchedules();
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
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(branch),
                          selected: selectedBranch == branch,
                          onSelected: (selected) {
                            selectedBranch = branch;
                            _filterSchedules();
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

                // Content
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _fetchSchedules,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : filteredSchedules.isEmpty
                              ? Center(
                                  child: Text(
                                    'No schedules found for ${selectedBranch == 'All' ? 'any branch' : selectedBranch}.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchSchedules,
                                  color: Colors.purple,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: filteredSchedules.length,
                                    itemBuilder: (context, index) {
                                      final schedule = filteredSchedules[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ScheduleDetailsScreen(
                                                  schedule: schedule.toJson(),
                                                ),
                                              ),
                                            );
                                          },
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
                                                    Icon(Icons.access_time, color: Colors.orange, size: width * 0.04),
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
                                                SizedBox(height: height * 0.015),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ScheduleDetailsScreen(
                                                            schedule: schedule.toJson(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.purple,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: width * 0.03,
                                                        vertical: height * 0.005,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'View Details',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: width * 0.035,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new schedule functionality to be implemented')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
