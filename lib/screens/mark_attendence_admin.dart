import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xl;
import 'dart:convert';
import '../widgets/custom_appbar.dart';

class MarkAttendenceAdmin extends StatefulWidget {
  const MarkAttendenceAdmin({super.key});

  @override
  State<MarkAttendenceAdmin> createState() => _MarkAttendenceAdminState();
}

class _MarkAttendenceAdminState extends State<MarkAttendenceAdmin> {
  final TextEditingController _messageController = TextEditingController();
  List<String> phoneNumbers = [];

  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        final bytes = result.files.first.bytes!;
        final excel = xl.Excel.decodeBytes(bytes);

        setState(() {
          phoneNumbers = [];
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
              // Start from index 1 to skip header row
              for (var i = 1; i < sheet.rows.length; i++) {
                var row = sheet.rows[i];
                if (row.isNotEmpty && row[phoneColumnIndex]?.value != null) {
                  String phone = row[phoneColumnIndex]!.value.toString();
                  // Remove any spaces and ensure proper format
                  phone = phone.replaceAll(' ', '');
                  if (!phone.startsWith('+91')) {
                    phone = '+91$phone';
                  }
                  phoneNumbers.add(phone);
                }
              }
            }
          }
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
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF661058).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF661058).withOpacity(0.4),
                    blurRadius: 130,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2B8B7B).withOpacity(0.01),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B8B7B).withOpacity(0.3),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBar(),
                  const SizedBox(height: 40),

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
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text(
                                      "Upload Excel/Sheets File",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Alata',
                                      ),
                                    ),
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
                              icon: Image.asset(
                                'assets/whatsapp.png',
                                height: 30,
                              ),
                              label: const Text(
                                "Send via WhatsApp",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Alata',
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
