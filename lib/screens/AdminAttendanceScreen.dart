import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xl;
import 'dart:convert';
import '../widgets/custom_appbar.dart';
import '../widgets/screens_background.dart';

class AdminMarkAttendence extends StatefulWidget {
  const AdminMarkAttendence({super.key});

  @override
  State<AdminMarkAttendence> createState() => _AdminMarkAttendenceState();
}

class _AdminMarkAttendenceState extends State<AdminMarkAttendence> {
  final TextEditingController _messageController = TextEditingController();
  List<String> phoneNumbers = [];

  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        // Clear existing numbers first
        setState(() {
          phoneNumbers.clear(); // Clear the list before loading new numbers
        });

        final bytes = result.files.first.bytes!;
        final excel = xl.Excel.decodeBytes(bytes);

        List<String> newPhoneNumbers = []; // Temporary list for new numbers

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;

          // Find the phone_number column index
          int? phoneColumnIndex;
          for (var i = 0; i < sheet.rows[0].length; i++) {
            String? headerValue = sheet.rows[0][i]?.value?.toString();
            if (headerValue != null) {
              headerValue = headerValue.toLowerCase().trim();
              if (headerValue.contains('phone') &&
                      headerValue.contains('number') ||
                  headerValue.contains('phonenumber') ||
                  headerValue == 'phone' ||
                  headerValue == 'mobile' ||
                  headerValue == 'contact' ||
                  headerValue == 'mobile number' ||
                  headerValue == 'contact number') {
                phoneColumnIndex = i;
                break;
              }
            }
          }

          // If phone_number column found, extract numbers
          if (phoneColumnIndex != null) {
            for (var i = 1; i < sheet.rows.length; i++) {
              var row = sheet.rows[i];
              if (row.isNotEmpty && row[phoneColumnIndex]?.value != null) {
                String phone = row[phoneColumnIndex]!.value.toString();
                phone = phone.replaceAll(' ', '');
                if (!phone.startsWith('+91')) {
                  phone = '+91$phone';
                }
                newPhoneNumbers.add(phone); // Add to temporary list
              }
            }
          }
        }

        // Update state with new numbers
        setState(() {
          phoneNumbers = newPhoneNumbers;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Loaded ${phoneNumbers.length} phone numbers"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing file: ${e.toString()}")),
      );
    }
  }

  Future<void> sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a message")));
      return;
    }

    if (phoneNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a file with phone numbers first"),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_API_URL/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message, "phoneNumbers": phoneNumbers}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Messages sent successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send messages")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
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
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Absentees",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alata',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Upload container
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Upload Attendance Sheet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Alata',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                    onPressed: pickExcelFile,
                                    label: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Upload Excel/Sheets File",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Alata',
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    icon:
                                        const SizedBox(), // Empty icon since we're using it in Row
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Phone numbers container
                          Container(
                            height:
                                screenSize.height * 0.3, // 30% of screen height
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child:
                                phoneNumbers.isEmpty
                                    ? const Center(
                                      child: Text(
                                        "No phone numbers loaded",
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 16,
                                          fontFamily: 'Alata',
                                        ),
                                      ),
                                    )
                                    : ListView.separated(
                                      itemCount: phoneNumbers.length,
                                      separatorBuilder:
                                          (context, index) => const Divider(
                                            color: Colors.white24,
                                            height: 1,
                                          ),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                color: Colors.white60,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                phoneNumbers[index],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                          ),

                          const SizedBox(height: 20),

                          // Message input
                          TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: "Enter Message Here",
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Send button
                          SizedBox(
                            width: screenSize.width,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                              ),
                              onPressed: sendMessage,
                              label: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Send via WhatsApp",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Alata',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image(
                                    image: AssetImage('assets/whatsapp.png'),
                                    height: 30,
                                  ),
                                ],
                              ),
                              icon: const SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
