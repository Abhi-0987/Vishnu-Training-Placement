import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:vishnu_training_and_placements/models/venue_model.dart';
import 'package:vishnu_training_and_placements/services/venue_service.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/services/Schedule_service.dart';
import 'package:vishnu_training_and_placements/screens/all_schedules_screen.dart';
import 'package:collection/collection.dart';

class ScheduleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailsScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<ScheduleDetailsScreen> createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  bool isAttendanceEnabled = false;
  bool showPostButton = false;

  Map<String, double> dataMap = {
    "Present": 75,
    "Absent": 25,
  };

  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController roomNoController;
  late TextEditingController branchController;

  late String originalDate;
  late String originalTime;
  late String originalLocation;
  late String originalRoomNo;
  late List<String> originalBranch;

  final VenueService _venueService = VenueService();
  List<Venue> _venues = [];
  bool _isLoadingVenues = true;
  final List<String> _branches = [
    'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AI & DS',
    'BME', 'PHE', 'CHEM', 'CSM', 'CSD', 'CSBS',
  ];
  final List<String> _timeSlots = [
    "9:30 - 11:15", "11:30 - 1:15", "2:20 - 3:40"
  ];

  late String _editedDate;
  late String _editedTime;
  late String _editedLocation;
  late String _editedRoomNo;
  late List<String> _editedBranch;

  @override
  void initState() {
    super.initState();
    isAttendanceEnabled = widget.schedule['attendanceEnabled'] ?? false;

    originalDate = widget.schedule['date'] ?? 'Not specified';
    originalTime = widget.schedule['time'] ?? 'Not specified';
    originalLocation = widget.schedule['location'] ?? 'Not specified';
    originalRoomNo = widget.schedule['roomNo'] ?? 'Not specified';

    final branchData = widget.schedule['studentBranch'];
    if (branchData is String) {
      originalBranch = branchData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } else if (branchData is List) {
      originalBranch = List<String>.from(branchData.map((item) => item.toString()));
    } else {
      originalBranch = [];
    }

    _editedDate = originalDate;
    _editedTime = originalTime;
    _editedLocation = originalLocation;
    _editedRoomNo = originalRoomNo;
    _editedBranch = List<String>.from(originalBranch);

    dateController = TextEditingController(text: originalDate);
    timeController = TextEditingController(text: originalTime);
    locationController = TextEditingController(text: originalLocation);
    roomNoController = TextEditingController(text: originalRoomNo);
    branchController = TextEditingController(text: originalBranch.join(', '));

    _fetchVenues();
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

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    roomNoController.dispose();
    branchController.dispose();
    super.dispose();
  }

  bool _isDataChanged() {
    bool branchesChanged = !const ListEquality().equals(originalBranch, _editedBranch);

    return _editedDate != originalDate ||
           _editedTime != originalTime ||
           _editedLocation != originalLocation ||
           _editedRoomNo != originalRoomNo ||
           branchesChanged;
  }

  Future<void> _editDate() async {
    DateTime initialDate;
    // Determine the first selectable date (today)
    DateTime firstAllowedDate = DateTime.now();
    // Remove time component to ensure today is selectable
    firstAllowedDate = DateTime(firstAllowedDate.year, firstAllowedDate.month, firstAllowedDate.day);

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

  Future<void> _editTime() async {
    String? selectedTime = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedTime = _editedTime;
        return AlertDialog(
          title: const Text('Select Time Slot'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _timeSlots.map((time) {
                  return RadioListTile<String>(
                    title: Text(time),
                    value: time,
                    groupValue: tempSelectedTime,
                    onChanged: (String? value) {
                      setDialogState(() {
                        tempSelectedTime = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(tempSelectedTime);
              },
            ),
          ],
        );
      },
    );

    if (selectedTime != null && selectedTime != _editedTime) {
      setState(() {
        _editedTime = selectedTime;
        showPostButton = _isDataChanged();
      });
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
    if (!_venues.any((v) => '${v.blockName} - Room ${v.roomNumber}' == currentSelection)) {
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
                items: _venues.map((venue) {
                  final venueString = "${venue.blockName} - Room ${venue.roomNumber}";
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
            }
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
        orElse: () => Venue(id: -1, blockName: '', roomNumber: '', latitude: 0, longitude: 0)
      );

      if (selectedVenue.id != -1 && (selectedVenue.blockName != _editedLocation || selectedVenue.roomNumber != _editedRoomNo)) {
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
                  children: _branches.map((branch) {
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

    if (selectedBranches != null && !const ListEquality().equals(selectedBranches, _editedBranch)) {
      setState(() {
        _editedBranch = selectedBranches;
        showPostButton = _isDataChanged();
      });
    }
  }

  void _deleteSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
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
                  const SnackBar(content: Text('Error: Schedule ID is missing')),
                );
                Navigator.pop(context);
                return;
              }

              final result = await ScheduleServices.deleteSchedule(scheduleId);

              Navigator.pop(context);

              if (result['success']) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AllSchedulesScreen()),
                  (Route<dynamic> route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Schedule deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${result['message'] ?? 'Failed to delete schedule'}')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleAttendance(bool value) {
    setState(() {
      isAttendanceEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance ${value ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_isDataChanged()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected.')),
      );
      return;
    }

    // Join the list of branches into a single comma-separated string
    String branchesString = _editedBranch.join(',');
    final updatedData = {
      'location': _editedLocation,
      'roomNo': _editedRoomNo,
      'date': _editedDate,
      'time': _editedTime,
      'studentBranch': branchesString,
    };

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

      // IMPORTANT: Check if mounted *before* interacting with context after await
      if (!mounted) {
        print("Widget not mounted after API call, returning."); // Log: Not mounted
        return; 
      }

      print("Attempting to dismiss loading dialog..."); // Log: Before dismissing dialog
      // Dismiss loading indicator FIRST
      // Try using rootNavigator: true
      Navigator.of(context, rootNavigator: true).pop(); 
      print("Loading dialog dismissed."); // Log: After dismissing dialog

      if (result['success'] == true) {
        print("Update successful. Showing SnackBar and popping screen."); // Log: Success path
        // Check mounted again before showing SnackBar or popping screen
        if (!mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully!')),
        );
        // Navigate back to the previous screen on success
        Navigator.pop(context, true); // Pop the details screen
      } else {
        print("Update failed. Showing error SnackBar. Error: ${result['message']}"); // Log: Failure path
        // Check mounted again before showing SnackBar
        if (!mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update schedule: ${result['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e, stackTrace) { // Catch stack trace for more info
       print("Error caught in _saveChanges: $e"); // Log: Error caught
       print("Stack trace: $stackTrace"); // Log: Stack trace

       // Check mounted again before interacting with context in catch block
      if (!mounted) {
        print("Widget not mounted in catch block, returning."); // Log: Not mounted in catch
        return; 
      }
      
      print("Attempting to dismiss loading dialog in catch block..."); // Log: Before pop in catch
      // Attempt to dismiss the dialog in case the error occurred before the first pop
      // Use rootNavigator: true here as well for consistency
      Navigator.of(context, rootNavigator: true).pop(); 
      print("Loading dialog dismissed in catch block (if it was still open)."); // Log: After pop in catch
      
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
    String displayTime = _editedTime;
    String displayLocation = _editedLocation;
    String displayRoomNo = _editedRoomNo;
    String displayBranch = _editedBranch.isEmpty ? 'Not specified' : _editedBranch.join(', ');
    String displayTitle = widget.schedule['title'] ?? 'Schedule Details';

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        showProfileIcon: true,
      ),
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
                  _buildDetailItem('Time', displayTime, _editTime),
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
                        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
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
                            color: Colors.white,
                          ),
                        ),
                        Switch(
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        PieChart(
                          dataMap: dataMap,
                          animationDuration: const Duration(milliseconds: 800),
                          chartLegendSpacing: 32,
                          chartRadius: MediaQuery.of(context).size.width / 2.5,
                          colorList: const [Colors.green, Colors.red],
                          initialAngleInDegree: 0,
                          chartType: ChartType.disc,
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatisticItem('Total Students', '100', Colors.blue),
                            const SizedBox(width: 16),
                            _buildStatisticItem('Present', '75', Colors.green),
                            const SizedBox(width: 16),
                            _buildStatisticItem('Absent', '25', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _deleteSchedule,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, VoidCallback onEditPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
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
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}