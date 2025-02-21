import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vishnu_training_and_placements/widgets/background.dart';
import 'package:vishnu_training_and_placements/widgets/card.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EventVenue(),
  ));
}

class EventVenue extends StatefulWidget {
  const EventVenue({super.key});

  @override
  _EventVenueState createState() => _EventVenueState();
}

class _EventVenueState extends State<EventVenue> {
  bool itSeminar = false;
  bool elnSeminar = false;
  bool auditorium = false;

  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  String selectedTime = "9:30 AM - 12:30 PM";
  String selectedLocation = '';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', height: screenHeight * 0.08), // Responsive Image
                SizedBox(width: screenWidth * 0.01),
                Text("Vishnu",
                    style: TextStyle(
                        fontSize: screenHeight * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alata',
                        color: Colors.white)),
                SizedBox(width: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Training and",
                        style: TextStyle(fontSize: screenHeight * 0.02,fontFamily: 'Alata', color: Colors.white)),
                    Text("Placements",
                        style: TextStyle(fontSize: screenHeight * 0.02,fontFamily: 'Alata', color: Colors.white)),
                  ],
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: screenHeight * 0.02, // Responsive avatar
              child: Text("A",
                  style: TextStyle(
                      fontSize: screenHeight * 0.02, fontWeight: FontWeight.bold,fontFamily: 'Alata', color: Colors.white)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          isShowbehindappbar(true), 
          Background(),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Manage Locations",
                      style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alata',
                          color: Colors.white)),
                  SizedBox(height: screenHeight * 0.02),
                  _buildLocationDropdown((val) {
                    setState(() {
                      selectedLocation = val ?? '';
                    });
                  }),
                  SizedBox(height: screenHeight * 0.03),
                  Text("Schedule",
                      style: TextStyle(
                          fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold,fontFamily: 'Alata', color: Colors.white)),
                  SizedBox(height: screenHeight * 0.02),
                  _buildCalendar(),
                  SizedBox(height: screenHeight * 0.03),
                  Text("Set Time",
                      style: TextStyle(
                          fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold,fontFamily: 'Alata', color: Colors.white)),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTimeSelection(),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        SizedBox(height: screenHeight * 0.02), // Add space
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02, horizontal: screenWidth * 0.05),
                          ),
                          child: Text("Post Attendance",
                              style: TextStyle(
                                  fontSize: screenHeight * 0.02, fontFamily: 'Alata',color: Colors.white)),
                        ),
                      ],
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
      ),
    );
  }
  Widget isShowbehindappbar(bool value) {
  return value ? Container(color: Colors.white) : Container();
  }

  Widget _buildTimeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeButton("9:30 AM - 12:30 PM"),
        _buildTimeButton("1:30 PM - 3:30 PM"),
      ],
    );
  }

  Widget _buildTimeButton(String time) {
    bool isSelected = selectedTime == time;
    return GestureDetector(
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
        child: Text(time, style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoCard() {
    return BlurredCard(
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
