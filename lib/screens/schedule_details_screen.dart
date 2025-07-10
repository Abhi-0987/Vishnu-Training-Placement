import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:vishnu_training_and_placements/models/schedule_model.dart';
import 'package:vishnu_training_and_placements/models/venue_model.dart';
import 'package:vishnu_training_and_placements/screens/admin_attendance_screen.dart';
import 'package:vishnu_training_and_placements/screens/manual_attendance_screen.dart';
import 'package:vishnu_training_and_placements/services/venue_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/screens/all_schedules_screen.dart';
import 'package:collection/collection.dart';

// ignore_for_file: depend_on_ referenced_packages
class ScheduleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailsScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailsScreen> createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  // Initialize with the actual 'mark' value from the schedule
  late bool isAttendanceEnabled;
  bool showPostButton = false;
  bool _isUpdatingMark = false; // Add a flag to prevent rapid toggling

  int presentCount = 0;
  int absentCount = 0;
  int totalStudents = 0;

  Map<String, double> dataMap = {"Present": 0, "Absent": 0};

  late TextEditingController dateController;
  late TextEditingController fromtimeController;
  late TextEditingController totimecontroller;
  late TextEditingController locationController;
  late TextEditingController roomNoController;
  late TextEditingController branchController;

  TimeOfDay fromTime = TimeOfDay(hour: 9, minute: 30);
  TimeOfDay toTime = TimeOfDay(hour: 11, minute: 15);

  late String originalDate;
  late String originalFromTime;
  late String originalToTime;
  late String originalLocation;
  late String originalRoomNo;
  late List<String> originalBranch;

  final VenueService _venueService = VenueService();
  List<Venue> _venues = [];
  bool _isLoadingVenues = true;
  final List<String> _branches = [
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT',
    'AI & DS',
    'BME',
    'PHE',
    'CHEM',
    'CSM',
    'CSD',
    'CSBS',
  ];

  late String _editedDate;
  late String _editedFromTime;
  late String _editedToTime;
  late String _editedLocation;
  late String _editedRoomNo;
  late List<String> _editedBranch;

  @override
  void initState() {
    super.initState();

    // Remove the date checking logic for past schedules
    // originalDate = widget.schedule['date'] ?? 'Not specified';
    // try {
    //   final scheduleDate = DateFormat('yyyy-MM-dd').parse(originalDate);
    //   final now = DateTime.now();
    //   final today = DateTime(now.year, now.month, now.day);
    //   _isPastSchedule = scheduleDate.isBefore(today);
    // } catch (e) {
    //   _isPastSchedule = false;
    //   print("Error parsing schedule date '$originalDate': $e. Assuming not a past schedule.");
    // }

    // Initialize isAttendanceEnabled directly from the 'mark' field
    isAttendanceEnabled = widget.schedule['mark'] ?? false;

    // Initialize original values and controllers as before
    originalDate = widget.schedule['date'] ?? 'Not specified';
    originalFromTime = widget.schedule['fromTime'] ?? 'Not specified';
    originalToTime = widget.schedule['toTime'] ?? 'Not specified';
    originalLocation = widget.schedule['location'] ?? 'Not specified';
    originalRoomNo = widget.schedule['roomNo'] ?? 'Not Specified';

    final branchData = widget.schedule['studentBranch'];
    if (branchData is String) {
      originalBranch =
          branchData
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
    } else if (branchData is List) {
      originalBranch = List<String>.from(
        branchData.map((item) => item.toString()),
      );
    } else {
      originalBranch = [];
    }

    _editedDate = originalDate;
    _editedFromTime = originalFromTime;
    _editedToTime = originalToTime;
    _editedLocation = originalLocation;
    _editedRoomNo = originalRoomNo;
    _editedBranch = List<String>.from(originalBranch);

    dateController = TextEditingController(text: originalDate);
    fromtimeController = TextEditingController(text: originalFromTime);
    totimecontroller = TextEditingController(text: originalToTime);
    locationController = TextEditingController(text: originalLocation);
    roomNoController = TextEditingController(text: originalRoomNo);
    branchController = TextEditingController(text: originalBranch.join(', '));

    _fetchVenues();
    _fetchAttendanceStats();
  }

  Future<void> _fetchVenues() async {
    try {
      setState(() {
        _isLoadingVenues = true;
      });
      final fetchedVenues = await _venueService.fetchVenues();
      if (mounted) {
        setState(() {
          _venues = fetchedVenues;
          _isLoadingVenues = false;
        });
      }
      print('Fetched venues successfully');
    } catch (e) {
      print('Error fetching venues in ScheduleDetailsScreen: $e');
      if (mounted) {
        setState(() {
          _isLoadingVenues = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load locations')),
        );
      }
    }
  }

  Future<void> _fetchAttendanceStats() async {
    final scheduleId = widget.schedule['id']?.toString();
    if (scheduleId == null) return;

    final result = await ScheduleServices.getAttendanceStatistics(scheduleId);
    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        presentCount = data['presentCount'] ?? 0;
        absentCount = data['absentCount'] ?? 0;
        totalStudents = data['totalStudents'] ?? 0;

        dataMap = {
          "Present": presentCount.toDouble(),
          "Absent": absentCount.toDouble(),
        };
      });
    } else {
      // fallback or error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load stats')),
      );
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    fromtimeController.dispose();
    totimecontroller.dispose();
    locationController.dispose();
    roomNoController.dispose();
    branchController.dispose();
    super.dispose();
  }

  bool _isDataChanged() {
    bool branchesChanged =
        !const ListEquality().equals(originalBranch, _editedBranch);

    return _editedDate != originalDate ||
        _editedFromTime != originalFromTime ||
        _editedToTime != originalToTime ||
        _editedLocation != originalLocation ||
        _editedRoomNo != originalRoomNo ||
        branchesChanged;
  }

  Future<void> _editDate() async {
    DateTime initialDate;
    // Determine the first selectable date (today)
    DateTime firstAllowedDate = DateTime.now();
    // Remove time component to ensure today is selectable
    firstAllowedDate = DateTime(
      firstAllowedDate.year,
      firstAllowedDate.month,
      firstAllowedDate.day,
    );

    try {
      // Attempt to parse the current date string
      initialDate = DateFormat('yyyy-MM-dd').parse(_editedDate);
      // If the parsed date is before today, set the initial date for the picker to today
      if (initialDate.isBefore(firstAllowedDate)) {
        initialDate = firstAllowedDate;
      }
    } catch (e) {
      // Fallback to today if parsing fails
      initialDate = firstAllowedDate; // Use the calculated firstAllowedDate
      print("Error parsing date '$_editedDate', using today's date. Error: $e");
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate, // Set the first selectable date to today
      lastDate: DateTime(2040), // Keep a reasonable future limit
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (formattedDate != _editedDate) {
        setState(() {
          _editedDate = formattedDate;
          showPostButton = _isDataChanged();
        });
      }
    }
  }

  Future<void> _editFromTime() async {
    // Parse current time from the string
    try {
      final currentTime = DateFormat('HH:mm').parse(_editedFromTime);
      fromTime = TimeOfDay(hour: currentTime.hour, minute: currentTime.minute);
    } catch (e) {
      fromTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (formattedTime != _editedFromTime) {
        setState(() {
          _editedFromTime = formattedTime;
          showPostButton = _isDataChanged();
        });
      }
    }
  }

  Future<void> _editToTime() async {
    // Parse current time from the string
    try {
      final currentTime = DateFormat('HH:mm').parse(_editedToTime);
      toTime = TimeOfDay(hour: currentTime.hour, minute: currentTime.minute);
    } catch (e) {
      toTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: toTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (formattedTime != _editedToTime) {
        setState(() {
          _editedToTime = formattedTime;
          showPostButton = _isDataChanged();
        });
      }
    }
  }

  Future<void> _editLocation() async {
    if (_isLoadingVenues) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Locations are still loading...')),
      );
      return;
    }
    if (_venues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No locations available to select.')),
      );
      return;
    }

    String? currentSelection = '$_editedLocation - Room $_editedRoomNo';
    if (!_venues.any(
      (v) => '${v.blockName} - Room ${v.roomNumber}' == currentSelection,
    )) {
      currentSelection = null;
    }

    String? selectedVenueString = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempSelection = currentSelection;
        return AlertDialog(
          title: const Text('Select Location'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return DropdownButton<String>(
                value: tempSelection,
                hint: const Text("Choose location"),
                isExpanded: true,
                items:
                    _venues.map((venue) {
                      final venueString =
                          "${venue.blockName} - Room ${venue.roomNumber}";
                      return DropdownMenuItem<String>(
                        value: venueString,
                        child: Text(venueString),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    tempSelection = newValue;
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(tempSelection),
            ),
          ],
        );
      },
    );

    if (selectedVenueString != null) {
      final selectedVenue = _venues.firstWhere(
        (v) => "${v.blockName} - Room ${v.roomNumber}" == selectedVenueString,
        orElse:
            () => Venue(
              id: -1,
              blockName: '',
              roomNumber: '',
              latitude: 0,
              longitude: 0,
            ),
      );

      if (selectedVenue.id != -1 &&
          (selectedVenue.blockName != _editedLocation ||
              selectedVenue.roomNumber != _editedRoomNo)) {
        setState(() {
          _editedLocation = selectedVenue.blockName;
          _editedRoomNo = selectedVenue.roomNumber;
          showPostButton = _isDataChanged();
        });
      }
    }
  }

  Future<void> _editBranch() async {
    List<String>? selectedBranches = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelection = List.from(_editedBranch);
        return AlertDialog(
          title: const Text('Select Branches'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _branches.map((branch) {
                        return CheckboxListTile(
                          title: Text(branch),
                          value: tempSelection.contains(branch),
                          onChanged: (bool? selected) {
                            setDialogState(() {
                              if (selected == true) {
                                tempSelection.add(branch);
                              } else {
                                tempSelection.remove(branch);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(tempSelection),
            ),
          ],
        );
      },
    );

    if (selectedBranches != null &&
        !const ListEquality().equals(selectedBranches, _editedBranch)) {
      setState(() {
        _editedBranch = selectedBranches;
        showPostButton = _isDataChanged();
      });
    }
  }

  void _deleteSchedule() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: const Text(
              'Are you sure you want to delete this schedule?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final scheduleId = widget.schedule['id']?.toString();
                  if (scheduleId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Schedule ID is missing'),
                      ),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  final result = await ScheduleServices.deleteSchedule(
                    scheduleId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (result['success']) {
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllSchedulesScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ??
                                'Schedule deleted successfully',
                          ),
                        ),
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${result['message'] ?? 'Failed to delete schedule'}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Modify _toggleAttendance to be async and call the service
  Future<void> _toggleAttendance(bool value) async {
    if (_isUpdatingMark) return; // Prevent updates if already updating

    setState(() {
      _isUpdatingMark = true; // Set updating flag
    });

    final scheduleId = widget.schedule['id']?.toString();
    if (scheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Schedule ID is missing')),
      );
      setState(() {
        _isUpdatingMark = false; // Reset flag on error
      });
      return;
    }

    // Call the service method
    final result = await ScheduleServices.updateScheduleMarkStatus(
      scheduleId,
      value,
    );

    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    if (result['success']) {
      // Update the local state ONLY if the API call was successful
      setState(() {
        isAttendanceEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Attendance status updated'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message if the API call failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${result['message'] ?? 'Failed to update status'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Optionally revert the switch state visually if the update failed,
      // although keeping it as the user intended might also be valid UX.
      // setState(() {
      //   isAttendanceEnabled = !value; // Revert state visually
      // });
    }

    setState(() {
      _isUpdatingMark = false; // Reset updating flag
    });
  }

  Future<void> _saveChanges() async {
    if (!_isDataChanged()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
      return;
    }

    // Join the list of branches into a single comma-separated string
    String branchesString = _editedBranch.join(',');
    final updatedData = {
      'location': _editedLocation,
      'roomNo': _editedRoomNo,
      'date': _editedDate,
      'fromTime': _editedFromTime,
      'toTime': _editedToTime,
      'studentBranch': branchesString,
    };

    print("Updated Data:");
    updatedData.forEach((key, value) {
      print("$key: $value");
    });

    print("Showing loading dialog..."); // Log: Before showing dialog
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      print("Calling updateSchedule API..."); // Log: Before API call
      final result = await ScheduleServices.updateSchedule(
        widget.schedule['id'].toString(),
        updatedData,
      );
      print("API call finished. Result: $result"); // Log: After API call

      // IMPORTANT: Check if mounted before interacting with context after await
      if (!mounted) {
        print(
          "Widget not mounted after API call, returning.",
        ); // Log: Not mounted
        return;
      }

      print(
        "Attempting to dismiss loading dialog...",
      ); // Log: Before dismissing dialog
      // Dismiss loading indicator FIRST
      // Try using rootNavigator: true
      Navigator.of(context, rootNavigator: true).pop();
      print("Loading dialog dismissed."); // Log: After dismissing dialog

      if (result['success'] == true) {
        print(
          "Update successful. Showing SnackBar and popping screen.",
        ); // Log: Success path
        // Check mounted again before showing SnackBar or popping screen
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully!')),
        );
        // Navigate back to the previous screen on success
        Navigator.pop(context, true); // Pop the details screen
      } else {
        print(
          "Update failed. Showing error SnackBar. Error: ${result['message']}",
        ); // Log: Failure path
        // Check mounted again before showing SnackBar
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update schedule: ${result['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      // Catch stack trace for more info
      print("Error caught in _saveChanges: $e"); // Log: Error caught
      print("Stack trace: $stackTrace"); // Log: Stack trace

      // Check mounted again before interacting with context in catch block
      if (!mounted) {
        print(
          "Widget not mounted in catch block, returning.",
        ); // Log: Not mounted in catch
        return;
      }

      print(
        "Attempting to dismiss loading dialog in catch block...",
      ); // Log: Before pop in catch
      // Attempt to dismiss the dialog in case the error occurred before the first pop
      // Use rootNavigator: true here as well for consistency
      Navigator.of(context, rootNavigator: true).pop();
      print(
        "Loading dialog dismissed in catch block (if it was still open).",
      ); // Log: After pop in catch

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    String displayDate = _editedDate;
    String displayFromTime = _editedFromTime;
    String displayToTime = _editedToTime;
    String displayLocation = _editedLocation;
    String displayRoomNo = _editedRoomNo;
    String displayBranch =
        _editedBranch.isEmpty ? 'Not specified' : _editedBranch.join(', ');
    String displayTitle = widget.schedule['title'] ?? 'Schedule Details';
    final Schedule schedule = Schedule.fromJson(widget.schedule);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showProfileIcon: true),
      body: Stack(
        children: [
          ScreensBackground(height: height, width: width),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailItem('Date', displayDate, _editDate),
                  _buildDetailItem('From', displayFromTime, _editFromTime),
                  _buildDetailItem('To', displayToTime, _editToTime),
                  _buildDetailItem('Location', displayLocation, _editLocation),
                  _buildDetailItem('Room No', displayRoomNo, _editLocation),
                  _buildDetailItem('Branch', displayBranch, _editBranch),

                  const SizedBox(height: 24),

                  if (showPostButton) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(
                        0x19FFFFFF,
                      ), // 0x19 = 10% opacity (0.1), FFFFFF = white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(
                          0x33FFFFFF,
                        ), // 0x33 = 20% opacity (0.2), FFFFFF = white),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enable Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textWhite,
                          ),
                        ),
                        _isUpdatingMark
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppConstants.textWhite,
                              ),
                            )
                            : Switch(
                              value: isAttendanceEnabled,
                              onChanged: _toggleAttendance,
                              activeColor: Colors.greenAccent,
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Attendance Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textWhite,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(
                        0x19FFFFFF,
                      ), // 0x19 = 10% opacity (0.1), FFFFFF = white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(
                          0x33FFFFFF,
                        ), // 0x33 = 20% opacity (0.2), FFFFFF = white),
                      ),
                    ),
                    child: Column(
                      children: [
                        PieChart(
                          dataMap: dataMap,
                          animationDuration: const Duration(milliseconds: 1000),
                          chartLegendSpacing: 24,
                          chartRadius: MediaQuery.of(context).size.width / 2.6,
                          colorList: const [
                            Color.fromARGB(255, 65, 188, 69),
                            Color.fromARGB(255, 241, 64, 51),
                          ],
                          initialAngleInDegree: -90,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 25,
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.bottom,
                            showLegends: true,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 1,
                            chartValueStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatisticItem(
                              'Total Students',
                              totalStudents.toString(),
                              Colors.blue,
                            ),
                            const SizedBox(width: 30),
                            _buildStatisticItem(
                              'Present',
                              presentCount.toString(),
                              Colors.green,
                            ),
                            const SizedBox(width: 30),
                            _buildStatisticItem(
                              'Absent',
                              absentCount.toString(),
                              Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ManualAttendanceScreen(
                                      scheduleId: int.parse(
                                        widget.schedule['id'].toString(),
                                      ),
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.people,
                            color: AppConstants.textWhite,
                          ),
                          label: const Text(
                            'Manual Attendance',
                            style: TextStyle(color: AppConstants.textWhite),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: AppConstants.textWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _deleteSchedule,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: AppConstants.textWhite,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16), // Spacing before the new button

                  if (schedule.isOver())
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminMarkAttendence(
                                    scheduleId: int.parse(schedule.id),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment_turned_in),
                        label: const Text(
                          'Message Sending',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailItem(
    String label,
    String value,
    VoidCallback onEditPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0x19FFFFFF), // 0x19 = 10% opacity (0.1), FFFFFF = white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(
            0x33FFFFFF,
          ), // 0x33 = 20% opacity (0.2), FFFFFF = white),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppConstants.textWhite,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppConstants.textWhite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Only show edit icon if the label is not 'Branch'
          if (label != 'Branch')
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
              onPressed: onEditPressed,
              tooltip: 'Edit $label',
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppConstants.textWhite),
        ),
      ],
    );
  }
}
