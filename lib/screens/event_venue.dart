// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vishnu_training_and_placements/models/venue_model.dart';
import 'package:vishnu_training_and_placements/services/schedule_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';
import 'package:vishnu_training_and_placements/services/venue_service.dart';

class EventVenueScreen extends StatefulWidget {
  const EventVenueScreen({super.key});

  @override
  State<EventVenueScreen> createState() => _EventVenueScreenState();
}

class _EventVenueScreenState extends State<EventVenueScreen> {
  final VenueService _venueService = VenueService();
  List<Venue> venues = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVenues();
  }

  Future<void> fetchVenues() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedVenues = await _venueService.fetchVenues();

      if (mounted) {
        setState(() {
          venues = fetchedVenues;
          isLoading = false;

          print('Venues fetched from database: ${venues.length} venues found');
          for (var venue in venues) {
            print(
              'Block: ${venue.blockName}, Room: ${venue.roomNumber}, Location: (${venue.latitude}, ${venue.longitude})',
            );
          }
        });
      }
    } catch (e) {
      print('Error in fetchVenues: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load venues: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  List<String> branches = [
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

  Map<String, List<String>> branchSections = {
    'CSE': ['CSE-A', 'CSE-B', 'CSE-C', 'CSE-D', 'CSE-E'],
    'ECE': ['ECE-A', 'ECE-B', 'ECE-C', 'ECE-D'],
    'EEE': ['EEE'],
    'MECH': ['MECH'],
    'CIVIL': ['CIVIL-A', 'CIVIL-B'],
    'IT': ['IT-A', 'IT-B', 'IT-C'],
    'AI & DS': ['AI & DS'],
    'BME': ['BME'],
    'PHE': ['PHE'],
    'CHEM': ['CHEM'],
    'CSM': ['CSM-A', 'CSM-B'],
    'CSD': ['CSD-A', 'CSD-B'],
    'CSBS': ['CSBS'],
  };

  List<String> selectedBranches = [];
  List<String> selectedSections = []; // Add this to track selected sections

  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  String selectedTime = "9:30 - 11:15";
  String selectedLocation = '';

  // Add this method to show section selection dialog
  Future<void> _showSectionSelectionDialog(String branch) async {
    List<String> sections = branchSections[branch] ?? [];
    List<String> tempSelectedSections = [];

    // Pre-select sections that are already selected
    for (String section in sections) {
      if (selectedSections.contains(section)) {
        tempSelectedSections.add(section);
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Sections for $branch'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return CheckboxListTile(
                      title: Text(section),
                      value: tempSelectedSections.contains(section),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedSections.add(section);
                          } else {
                            tempSelectedSections.remove(section);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Remove any previously selected sections for this branch
                    selectedSections.removeWhere(
                      (section) => section.startsWith('$branch-'),
                    );

                    // Add newly selected sections
                    selectedSections.addAll(tempSelectedSections);

                    Navigator.pop(context);

                    // Update the state to reflect changes
                    this.setState(() {});
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modify the _scheduleClass method to include sections
  Future<void> _scheduleClass() async {
    setState(() {
      isLoading = true;
    });
    // --- Validation Checks ---
    if (selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if location is not selected
    }

    // Check if a time slot is selected (it has a default, but good to check)
    if (selectedTime.isEmpty) {
      // Or check against a specific "not selected" value if applicable
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if time is not selected
    }

    if (selectedBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one branch.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if no branches are selected
    }
    // --- End Validation Checks ---

    final parts = selectedLocation.split(' - Room ');
    final blockName = parts.isNotEmpty ? parts[0] : '';
    final roomNo = parts.length > 1 ? parts[1] : '';

    // Use sections if available, otherwise use branches
    String branchesString =
        selectedSections.isEmpty
            ? selectedBranches.join(',')
            : selectedSections.join(',');

    final scheduleData = {
      "location": blockName,
      "roomNo": roomNo,
      "date": selectedDate.toIso8601String().split('T')[0],
      "time": selectedTime,
      "studentBranch": branchesString,
    };

    // Add a print statement here to verify the map before sending
    print('Constructed scheduleData: $scheduleData');

    try {
      // Ensure we're sending proper JSON data
      final result = await ScheduleServices.saveSchedule(scheduleData);

      // Check context before showing SnackBar
      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to create schedule'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Schedule error: $e');
      // Check context before showing SnackBar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
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
          ScreensBackground(height: height, width: width),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manage Locations",
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _buildLocationDropdown((val) {
                      setState(() {
                        selectedLocation = val ?? '';
                      });
                    }),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Schedule",
                      style: TextStyle(
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _buildCalendar(),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Set Time",
                      style: TextStyle(
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _buildTimeSelection(),
                    SizedBox(height: height * 0.03),
                    // Add heading for branch selection
                    Text(
                      "Select Branches",
                      style: TextStyle(
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _buildBranchSelector(),
                    SizedBox(height: height * 0.03),
                    Center(
                      child: Column(
                        children: [
                          _buildInfoCard(width),
                          SizedBox(height: height * 0.02),
                          isLoading
                              ? CircularProgressIndicator(
                                color: AppConstants.primaryColor,
                              )
                              : ElevatedButton(
                                onPressed: _scheduleClass,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.015,
                                    horizontal: width * 0.04,
                                  ),
                                ),
                                child: Text(
                                  "Schedule Class",
                                  style: TextStyle(
                                    fontSize: height * 0.025,
                                    fontFamily: 'Alata',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown(Function(String?) onChanged) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.purple));
    }

    if (venues.isEmpty) {
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              "Could not load venues. Please check your connection to the server.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchVenues,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text("Choose your location", style: TextStyle(color: Colors.white)),
      onChanged: (value) {
        onChanged(value);
        if (value != null) {
          final selectedVenue = venues.firstWhere(
            (venue) => "${venue.blockName} - Room ${venue.roomNumber}" == value,
            orElse:
                () => Venue(
                  id: 0,
                  blockName: '',
                  roomNumber: '',
                  latitude: 0,
                  longitude: 0,
                ),
          );

          if (selectedVenue.id != 0) {
            print('Selected venue details:');
            print('Block: ${selectedVenue.blockName}');
            print('Room: ${selectedVenue.roomNumber}');
            print(
              'Coordinates: (${selectedVenue.latitude}, ${selectedVenue.longitude})',
            );
          }
        }
      },
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.black,
      items:
          venues.map((venue) {
            return DropdownMenuItem<String>(
              value: "${venue.blockName} - Room ${venue.roomNumber}",
              child: Text(
                "${venue.blockName} - Room ${venue.roomNumber}",
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        focusedDay: focusedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            selectedDate = selectedDay;
            focusedDate = focusedDay;
          });
        },
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2040, 12, 31),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        enabledDayPredicate: (day) {
          return !day.isBefore(DateTime.now().subtract(Duration(days: 1)));
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayDecoration: BoxDecoration(
            color: Color.fromRGBO(
              128,
              0,
              128,
              0.3,
            ), // Purple (RGB 128,0,128) with 0.3 opacity
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: Colors.black),
          disabledTextStyle: TextStyle(color: Colors.grey.shade400),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimeButton("9:30 - 11:15"),
            SizedBox(width: 10),
            _buildTimeButton("11:30 - 1:15"),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            _buildTimeButton("2:20 - 3:40"),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeButton(String time) {
    bool isSelected = selectedTime == time;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTime = time;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple : Colors.grey[800],
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Wrap(
      spacing: 10, // Increased horizontal spacing between chips
      runSpacing: 10, // Added vertical spacing between rows of chips
      children:
          branches.map((branch) {
            final isSelected = selectedBranches.contains(branch);
            // Check if any section of this branch is selected
            final hasSections = selectedSections.any(
              (section) => section.startsWith('$branch-'),
            );

            return FilterChip(
              label: Text(branch, style: TextStyle(color: Colors.white)),
              selected: isSelected || hasSections,
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.purple,
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ), // Added padding inside chips
              onSelected: (bool selected) {
                if (selected) {
                  // Show section selection dialog when branch is selected
                  _showSectionSelectionDialog(branch);
                  if (!selectedBranches.contains(branch)) {
                    setState(() {
                      selectedBranches.add(branch);
                    });
                  }
                } else {
                  setState(() {
                    selectedBranches.remove(branch);
                    // Remove all sections of this branch
                    selectedSections.removeWhere(
                      (section) => section.startsWith('$branch-'),
                    );
                  });
                }
              },
            );
          }).toList(),
    );
  }

  Widget _buildInfoCard(double width) {
    // Create a formatted string that shows branches with their sections
    String branchesText = '';
    if (selectedSections.isEmpty && selectedBranches.isEmpty) {
      branchesText = 'None selected';
    } else if (selectedSections.isEmpty) {
      branchesText = selectedBranches.join(', ');
    } else {
      branchesText = selectedSections.join(', ');
    }

    return OpaqueContainer(
      width: width,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Location: $selectedLocation",
              style: TextStyle(
                color: AppConstants.textWhite,
                fontFamily: 'Alata',
                fontSize: 18,
              ),
            ),
            Divider(color: AppConstants.textWhite),
            Text(
              "Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}",
              style: TextStyle(
                color: AppConstants.textWhite,
                fontFamily: 'Alata',
                fontSize: 18,
              ),
            ),
            Divider(color: AppConstants.textWhite),
            Text(
              "Time: $selectedTime",
              style: TextStyle(
                color: AppConstants.textWhite,
                fontFamily: 'Alata',
                fontSize: 18,
              ),
            ),
            Divider(color: AppConstants.textWhite),
            Text(
              "Branches: $branchesText",
              style: TextStyle(
                color: AppConstants.textWhite,
                fontFamily: 'Alata',
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
