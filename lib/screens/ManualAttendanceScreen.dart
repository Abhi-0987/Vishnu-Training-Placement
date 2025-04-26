import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/screens_background.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  bool _isLoading = false;
  final List<Student> _students = [];
  final List<Student> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _generateDummyStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateDummyStudents() {
    // Generate 50 dummy students with email IDs
    for (int i = 1; i <= 50; i++) {
      String studentId = i.toString().padLeft(4, '0');
      _students.add(
        Student(email: "student${studentId}@vishnu.edu.in", isSelected: false),
      );
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

  void _selectAllStudents(bool value) {
    setState(() {
      for (var student in _students) {
        student.isSelected = value;
      }

      if (value) {
        _selectedStudents.clear();
        _selectedStudents.addAll(_students);
      } else {
        _selectedStudents.clear();
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
        _isLoading = true;
      });

      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Attendance marked for ${_selectedStudents.length} students",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear selections
      setState(() {
        for (var student in _students) {
          student.isSelected = false;
        }
        _selectedStudents.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error marking attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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

                  // Remove the "Select all checkbox" container that was here

                  // Student list - simplified to only show email
                  Expanded(
                    child: Container(
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
                            (context, index) =>
                                const Divider(color: Colors.white24, height: 1),
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return ListTile(
                            leading: Checkbox(
                              value: student.isSelected,
                              onChanged: (value) {
                                _toggleStudentSelection(student);
                              },
                              activeColor: Colors.purple,
                              checkColor: Colors.white,
                            ),
                            title: Text(
                              student.email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                      onPressed: _isLoading ? null : _markAttendance,
                      child:
                          _isLoading
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

  Student({required this.email, this.isSelected = false});
}
