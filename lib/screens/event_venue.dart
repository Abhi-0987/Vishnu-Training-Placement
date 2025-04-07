import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vishnu_training_and_placements/widgets/custom_appbar.dart';
import 'package:vishnu_training_and_placements/widgets/opaque_container.dart';
import 'package:vishnu_training_and_placements/widgets/screens_background.dart';

class EventVenueScreen extends StatefulWidget {
  const EventVenueScreen({super.key});

  @override
  _EventVenueScreenState createState() => _EventVenueScreenState();
}

class _EventVenueScreenState extends State<EventVenueScreen> {
  bool itSeminar = false;
  bool elnSeminar = false;
  bool auditorium = false;

  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  String selectedTime = "9:30 - 11:15";  // Updated default time
  String selectedLocation = '';

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
          SafeArea(child: 
          Padding(
            padding: EdgeInsets.all(width * 0.04), // Responsive padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Manage Locations",
                      style: TextStyle(
                          fontSize: height * 0.02,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alata',
                          color: Colors.white)),
                  SizedBox(height: height * 0.02),
                  _buildLocationDropdown((val) {
                    setState(() {
                      selectedLocation = val ?? '';
                    });
                  }),
                  SizedBox(height: height * 0.03),
                  Text("Schedule",
                      style: TextStyle(
                          fontSize: height * 0.025, fontWeight: FontWeight.bold,fontFamily: 'Alata', color: Colors.white)),
                  SizedBox(height: height * 0.02),
                  _buildCalendar(),
                  SizedBox(height: height * 0.03),
                  Text("Set Time",
                      style: TextStyle(
                          fontSize: height * 0.025, fontWeight: FontWeight.bold,fontFamily: 'Alata', color: Colors.white)),
                  SizedBox(height: height * 0.02),
                  _buildTimeSelection(),
                  SizedBox(height: height * 0.03),
                  Center(
                    child: Column(
                      children: [
                        _buildInfoCard(width),
                        SizedBox(height: height * 0.02), // Add space
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.02, horizontal: width * 0.05),
                          ),
                          child: Text("Schedule Class",
                              style: TextStyle(
                                  fontSize: height * 0.02, fontFamily: 'Alata',color: Colors.white)),
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
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.black,
      items: [
        DropdownMenuItem<String>(value: 'IT Seminar Hall', child: Text("IT Seminar Hall", style: TextStyle(color: Colors.white))),
        DropdownMenuItem<String>(value: 'ELN Seminar', child: Text("ELN Seminar", style: TextStyle(color: Colors.white))),
        DropdownMenuItem<String>(value: 'Auditorium', child: Text("Auditorium", style: TextStyle(color: Colors.white))),
      ],
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
        // Add this to disable past dates
        enabledDayPredicate: (day) {
          // Allow only today and future dates
          return !day.isBefore(DateTime.now().subtract(Duration(days: 1)));
        },
        // Add calendar style customization
        calendarStyle: CalendarStyle(
          // Selected day customization - violet color
          selectedDecoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.white),
          // Today's day customization
          todayDecoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: Colors.black),
          // Disabled days (past dates)
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
  Widget isShowbehindappbar(bool value) {
  return value ? Container(color: Colors.white) : Container();
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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            time, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black, 
              fontSize: 16
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(width) {
    return OpaqueContainer(
      width: width,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Location: $selectedLocation", style: TextStyle(color: Colors.white,fontFamily: 'Alata', fontSize: 18)),
            Divider(color: Colors.white),
            Text("Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}", style: TextStyle(color: Colors.white,fontFamily: 'Alata', fontSize: 18)),
            Divider(color: Colors.white),
            Text("Time: $selectedTime", style: TextStyle(color: Colors.white,fontFamily: 'Alata', fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
