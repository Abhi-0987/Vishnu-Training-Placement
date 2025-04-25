import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/services/api_services.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/screens_background.dart';
import 'package:get/get.dart';
import '../controllers/admin_attendance_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'ManualAttendanceScreen.dart';

class AdminMarkAttendence extends StatefulWidget {
  const AdminMarkAttendence({super.key});

  @override
  State<AdminMarkAttendence> createState() => _AdminMarkAttendenceState();
}

class _AdminMarkAttendenceState extends State<AdminMarkAttendence> {
  final AdminAttendanceController controller = Get.put(
    AdminAttendanceController(),
  );
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> pickExcelFile() async {
    try {
      // Set only this button's loading state to true
      controller.isUploadingExcel.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        // Clear existing numbers first
        setState(() {
          controller
              .clearPhoneNumbers(); // Clear the list before loading new numbers
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
          controller.addPhoneNumbers(newPhoneNumbers);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Loaded ${newPhoneNumbers.length} phone numbers"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing file: ${e.toString()}")),
      );
    } finally {
      // Reset only this button's loading state
      controller.isUploadingExcel.value = false;
    }
  }

  // Update the fetchContactsFromApi method
  Future<void> fetchContactsFromApi() async {
    try {
      // Set only this button's loading state to true
      controller.isFetchingContacts.value = true;

      // Remove the controller loading state
      // controller.setLoading(true); - Remove this line

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      setState(() {
        controller.isFetchingContacts.value = true;
      });

      // Define headers to address the 403 error
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Make API call to fetch contacts with headers
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/contacts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> contactsJson = json.decode(response.body);

        // Clear existing numbers first
        controller.clearPhoneNumbers();

        // Extract phone numbers from contacts
        List<String> newPhoneNumbers = [];
        for (var contact in contactsJson) {
          String phone = contact['phoneNumber'] ?? '';
          if (phone.isNotEmpty) {
            phone = phone.replaceAll(' ', '');
            if (!phone.startsWith('+91')) {
              phone = '+91$phone';
            }
            newPhoneNumbers.add(phone);
          }
        }

        // Update state with new numbers
        setState(() {
          controller.addPhoneNumbers(newPhoneNumbers);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Fetched ${newPhoneNumbers.length} contacts from API",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
          'Failed to load contacts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching contacts: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      controller.isFetchingContacts.value = false;
    }
  }

  // Add these imports at the top of the file

  // Update the downloadExcelFile method
  Future<void> downloadExcelFile() async {
    try {
      controller.isDownloadingExcel.value = true;

      print("Starting Excel download process...");

      // Fetch all data from the table
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Define headers for the request
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("Fetching all data from the table...");
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/contacts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> tableData = json.decode(response.body);
        print(
          "Successfully fetched ${tableData.length} records from the table",
        );

        // Create a new Excel file
        final excel = xl.Excel.createExcel();
        final sheet = excel.sheets[excel.getDefaultSheet()!]!;

        // Add headers based on the keys in the first record
        if (tableData.isNotEmpty) {
          final headers = tableData.first.keys.toList();

          // Add header row with styling
          for (int i = 0; i < headers.length; i++) {
            var headerCell = sheet.cell(
              xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
            );
            headerCell.value = xl.TextCellValue(headers[i]);
            headerCell.cellStyle = xl.CellStyle(
              bold: true,
              horizontalAlign: xl.HorizontalAlign.Center,
            );
          }

          // Add data rows
          for (int rowIndex = 0; rowIndex < tableData.length; rowIndex++) {
            final record = tableData[rowIndex];

            for (int colIndex = 0; colIndex < headers.length; colIndex++) {
              final key = headers[colIndex];
              final value = record[key]?.toString() ?? '';

              sheet
                  .cell(
                    xl.CellIndex.indexByColumnRow(
                      columnIndex: colIndex,
                      rowIndex: rowIndex + 1,
                    ),
                  )
                  .value = xl.TextCellValue(value);
            }
          }
        } else {
          print("No data found in the table");
          throw Exception('No data found in the table');
        }

        // Generate the Excel file bytes
        final bytes = excel.save();

        if (bytes != null) {
          // Get the file name with timestamp
          String fileName =
              'contacts-${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year}.xlsx';
          print("Generated filename: $fileName");

          if (kIsWeb) {
            print("Running on web platform, using browser download...");
            // For web platform
            final blob = html.Blob([Uint8List.fromList(bytes)]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor =
                html.AnchorElement(href: url)
                  ..setAttribute('download', fileName)
                  ..click();
            html.Url.revokeObjectUrl(url);
            print("Web download initiated for file: $fileName");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Excel file downloaded successfully"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            print("Running on mobile platform, saving to downloads folder...");
            // For mobile platforms
            try {
              // Create a temporary file in the app's documents directory
              final directory = await getApplicationDocumentsDirectory();
              final filePath = '${directory.path}/$fileName';
              print("Saving file to: $filePath");

              final file = File(filePath);
              await file.writeAsBytes(bytes);
              print("File successfully written to: $filePath");

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Excel file saved to: $filePath"),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              print("Error saving file: $e");
              throw Exception('Failed to save Excel file: $e');
            }
          }
        } else {
          print("Failed to generate Excel bytes");
          throw Exception('Failed to generate Excel file bytes');
        }
      } else {
        print(
          "Failed to fetch data from table: ${response.statusCode} - ${response.body}",
        );
        throw Exception(
          'Failed to fetch data from table: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Error in downloadExcelFile: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading Excel file: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      // Fallback to using existing phone numbers if API call fails
      _generateExcelFromPhoneNumbers();
    } finally {
      controller.isDownloadingExcel.value = false;
      print("Excel download process completed");
    }
  }

  // Helper method to generate Excel from phone numbers if API call fails
  Future<void> _generateExcelFromPhoneNumbers() async {
    try {
      print("Falling back to generating Excel from phone numbers...");

      if (controller.phoneNumbers.isEmpty) {
        print("No phone numbers available");
        throw Exception('No phone numbers available to export');
      }

      // Create a new Excel file
      final excel = xl.Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet()!]!;

      // Add header
      var header = sheet.cell(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      );
      header.value = xl.TextCellValue('Phone Number');
      header.cellStyle = xl.CellStyle(
        bold: true,
        horizontalAlign: xl.HorizontalAlign.Center,
      );

      // Add phone numbers
      for (int i = 0; i < controller.phoneNumbers.length; i++) {
        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(controller.phoneNumbers[i]);
      }

      // Generate the Excel file bytes
      final bytes = excel.save();

      if (bytes != null) {
        // Get the file name with timestamp
        String fileName =
            'phone_numbers_${DateTime.now().millisecondsSinceEpoch}.xlsx';

        if (kIsWeb) {
          // For web platform
          final blob = html.Blob([Uint8List.fromList(bytes)]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor =
              html.AnchorElement(href: url)
                ..setAttribute('download', fileName)
                ..click();
          html.Url.revokeObjectUrl(url);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Excel file generated from phone numbers"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // For mobile platforms
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Excel file saved to: $filePath"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("Error in fallback Excel generation: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to generate Excel file: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
                                  // Changed from Row to Column for button layout
                                  Column(
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 20,
                                          ),
                                        ),
                                        onPressed:
                                            controller.isUploadingExcel.value
                                                ? null
                                                : () {
                                                  // Wrap in anonymous function to prevent cross-triggering
                                                  pickExcelFile();
                                                },
                                        label: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Upload Excel File",
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
                                        icon: const SizedBox(),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ), // Vertical spacing between buttons
                                      Obx(
                                        () => ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                          ),
                                          onPressed:
                                              controller
                                                      .isFetchingContacts
                                                      .value
                                                  ? null
                                                  : () {
                                                    // Wrap in anonymous function to prevent cross-triggering
                                                    fetchContactsFromApi();
                                                  },
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                controller
                                                        .isFetchingContacts
                                                        .value
                                                    ? "Fetching..."
                                                    : "Fetch from API",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: 'Alata',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.cloud_download,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                          icon: const SizedBox(),
                                        ),
                                      ),
                                      // Add download Excel button
                                      const SizedBox(height: 10),
                                      Obx(
                                        () => ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                          ),
                                          onPressed:
                                              controller.phoneNumbers.isEmpty ||
                                                      controller
                                                          .isDownloadingExcel
                                                          .value
                                                  ? null
                                                  : () {
                                                    // Wrap in anonymous function to prevent cross-triggering
                                                    downloadExcelFile();
                                                  },
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                controller
                                                        .isDownloadingExcel
                                                        .value
                                                    ? "Downloading..."
                                                    : "Download Excel",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: 'Alata',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.download,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                          icon: const SizedBox(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Phone numbers container
                          Obx(
                            () => Container(
                              height:
                                  screenSize.height *
                                  0.3, // 30% of screen height
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
                                  controller.phoneNumbers.isEmpty
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
                                        itemCount:
                                            controller.phoneNumbers.length,
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
                                                  controller
                                                      .phoneNumbers[index],
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
                          ),

                          const SizedBox(height: 20),

                          // Message input
                          TextField(
                            controller: _messageController,
                            onChanged: controller.setMessage,
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
                            child: Obx(
                              () => ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                ),
                                onPressed:
                                    controller.isSendingMessages.value
                                        ? null
                                        : () async {
                                          // Call the method directly from here instead of relying on the controller
                                          if (controller.phoneNumbers.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "No phone numbers to send messages to",
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          if (controller.message.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "Please enter a message",
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          try {
                                            controller.isSendingMessages.value =
                                                true;
                                            final response =
                                                await ApiService.sendBulkMessages(
                                                  controller.phoneNumbers
                                                      .toList(),
                                                  controller.message.value,
                                                );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(response),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 4),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        "Failed to send messages: ${e.toString()}",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 4),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          } finally {
                                            controller.isSendingMessages.value =
                                                false;
                                          }
                                        },
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      controller.isSendingMessages.value
                                          ? "Sending..."
                                          : "Send via WhatsApp",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Alata',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Image(
                                      image: AssetImage('assets/whatsapp.png'),
                                      height: 30,
                                    ),
                                  ],
                                ),
                                icon: const SizedBox(),
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
    );
  }
}
