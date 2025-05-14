import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/screens_background.dart';

class ManualAttendanceScreen extends StatefulWidget {
  final int scheduleId;

  const ManualAttendanceScreen({super.key, required this.scheduleId});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  final List<Student> _students = [];
  final List<Student> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _errorMessage = '';
  // Add schedule details
  Map<String, dynamic> _scheduleDetails = {};
  bool _loadingScheduleDetails = true;

  // Base URL for API calls
  String baseUrl = AppConstants.backendUrl; // For Android emulator

  @override
  void initState() {
    super.initState();
    _fetchScheduleDetails();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch schedule details
  Future<void> _fetchScheduleDetails() async {
    setState(() {
      _loadingScheduleDetails = true;
    });

    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ' ';

      // Make API call to get schedule details
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/schedules/${widget.scheduleId}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your server or internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _scheduleDetails = data;
          _loadingScheduleDetails = false;
        });
      } else {
        throw Exception(
          'Failed to load schedule details: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _loadingScheduleDetails = false;
      });
    }
  }

  // Fetch students for this schedule
  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ' ';

      // Make API call to get students for this schedule
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/schedules/${widget.scheduleId}/students'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your server or internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        // Debug the response

        // Check if response body is empty
        if (response.body.isEmpty) {
          setState(() {
            _students.clear();
            _isLoading = false;
          });
          return;
        }

        // Try to parse the response with more robust error handling
        try {
          // Check if the response starts with '<' which indicates it's not JSON
          if (response.body.trim().startsWith('<')) {
            throw Exception(
              'Server returned HTML/XML instead of JSON. Check server logs.',
            );
          }

          // Try to decode the JSON
          final List<dynamic> studentsJson = json.decode(response.body);

          setState(() {
            _students.clear();
            for (var studentJson in studentsJson) {
              if (studentJson is Map<String, dynamic>) {
                _students.add(
                  Student(
                    email: studentJson['email'] ?? '',
                    isSelected: false,
                    isPresent: studentJson['present'] ?? false,
                  ),
                );
              }
            }
            _isLoading = false;
          });
        } catch (e) {
          throw Exception(
            'Failed to parse response: ${e.toString()}. Response was: ${response.body.substring(0, min(100, response.body.length))}...',
          );
        }
      } else {
        // Try to parse error message from response
        String errorMsg = 'Failed to load students: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMsg = errorData['error'];
          }
        } catch (_) {
          // If we can't parse the error, use the default message
          if (response.body.isNotEmpty) {
            errorMsg +=
                ' - ${response.body.substring(0, min(100, response.body.length))}...';
          }
        }

        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleStudentSelection(Student student) {
    setState(() {
      student.isSelected = !student.isSelected;
      if (student.isSelected) {
        _selectedStudents.add(student);
      } else {
        _selectedStudents.removeWhere((s) => s.email == student.email);
      }
    });
  }

  Future<void> _markAttendance() async {
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one student"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ' ';

      // Prepare the list of emails to mark as present
      final List<String> emails =
          _selectedStudents.map((s) => s.email).toList();

      // Make API call to mark attendance
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/schedules/${widget.scheduleId.toString()}/mark-attendance',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(emails),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your server or internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Attendance marked for ${_selectedStudents.length} students",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the student list
        await _fetchStudents();

        // Clear selections
        setState(() {
          _selectedStudents.clear();
        });
      } else {
        throw Exception('Failed to mark attendance: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error marking attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return _students;
    }

    return _students.where((student) {
      return student.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          ScreensBackground(height: screenSize.height, width: screenSize.width),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manual Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Alata',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Selected: ${_selectedStudents.length} students",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Alata',
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by email",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.purple,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // Student list
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            )
                            : _errorMessage.isNotEmpty
                            ? Center(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800.withAlpha(76),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withAlpha(26),
                                  width: 1,
                                ),
                              ),
                              child: ListView.separated(
                                itemCount: _filteredStudents.length,
                                separatorBuilder:
                                    (context, index) => const Divider(
                                      color: Colors.white24,
                                      height: 1,
                                    ),
                                itemBuilder: (context, index) {
                                  final student = _filteredStudents[index];
                                  return ListTile(
                                    leading: Checkbox(
                                      value: student.isSelected,
                                      onChanged:
                                          student.isPresent
                                              ? null // Disable checkbox if already present
                                              : (value) {
                                                _toggleStudentSelection(
                                                  student,
                                                );
                                              },
                                      activeColor: Colors.purple,
                                      checkColor: Colors.white,
                                    ),
                                    title: Text(
                                      student.email,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration:
                                            student.isPresent
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                    trailing:
                                        student.isPresent
                                            ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                            : null,
                                  );
                                },
                              ),
                            ),
                  ),

                  const SizedBox(height: 15),

                  // Mark attendance button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          (_isSubmitting || _selectedStudents.isEmpty)
                              ? null
                              : _markAttendance,
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Mark Attendance",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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

class Student {
  final String email;
  bool isSelected;
  final bool isPresent;

  Student({
    required this.email,
    this.isSelected = false,
    this.isPresent = false,
  });
}
