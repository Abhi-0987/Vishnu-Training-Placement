import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/manual_attendance_service.dart';
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
  Map<String, dynamic> _scheduleDetails = {};
  bool _loadingScheduleDetails = true;

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

  Future<void> _fetchScheduleDetails() async {
    setState(() => _loadingScheduleDetails = true);
    try {
      final details = await AttendanceService.fetchScheduleDetails(widget.scheduleId);
      setState(() {
        _scheduleDetails = details;
        _loadingScheduleDetails = false;
      });
    } catch (_) {
      setState(() => _loadingScheduleDetails = false);
    }
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final students = await AttendanceService.fetchStudents(widget.scheduleId);
      setState(() {
        _students
          ..clear()
          ..addAll(students);
        _isLoading = false;
      });
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
        const SnackBar(content: Text("Please select at least one student"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      final emails = _selectedStudents.map((s) => s.email).toList();
      await AttendanceService.markAttendance(widget.scheduleId, emails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance marked for ${_selectedStudents.length} students"), backgroundColor: Colors.green),
      );
      await _fetchStudents();
      setState(() => _selectedStudents.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error marking attendance: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((s) => s.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                  const Text("Manual Attendance", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Alata')),
                  const SizedBox(height: 5),
                  Text("Selected: ${_selectedStudents.length} students", style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Alata')),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by email",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.purple),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                        : _errorMessage.isNotEmpty
                            ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800.withAlpha(76),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withAlpha(26), width: 1),
                                ),
                                child: ListView.separated(
                                  itemCount: _filteredStudents.length,
                                  separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1),
                                  itemBuilder: (context, index) {
                                    final student = _filteredStudents[index];
                                    return ListTile(
                                      leading: Checkbox(
                                        value: student.isSelected,
                                        onChanged: student.isPresent ? null : (value) => _toggleStudentSelection(student),
                                        activeColor: Colors.purple,
                                        checkColor: Colors.white,
                                      ),
                                      title: Text(
                                        student.email,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: student.isPresent ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      trailing: student.isPresent ? const Icon(Icons.check_circle, color: Colors.green) : null,
                                    );
                                  },
                                ),
                              ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (_isSubmitting || _selectedStudents.isEmpty) ? null : _markAttendance,
                      child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Mark Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
