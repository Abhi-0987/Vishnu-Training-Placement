import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xl;
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class WhatsappServices {
  static const String baseUrl = AppConstants.backendUrl;

  static Future<List<String>> fetchAbsentees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/whatsapp/numbers'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>().toList();
      } else {
        throw Exception(
          "Failed to load phone numbers. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to connect to server");
    }
  }

  static Future<bool> checkServerConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> sendBulkMessages(
    List<String> phoneNumbers,
    String message,
  ) async {
    int successCount = 0;
    int failureCount = 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      for (var phoneNumber in phoneNumbers) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/api/whatsapp/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // Add authorization header
            },
            body: jsonEncode({
              'phone': phoneNumber,
              'message': message,
              'type': 'whatsapp',
            }),
          );

          if (response.statusCode == 200) {
            successCount++;
          } else {
            failureCount++;
            var errorMessage = "Unknown error";
            try {
              var jsonResponse = json.decode(response.body);
              errorMessage = jsonResponse['error'] ?? errorMessage;
            } catch (e) {
              // Unable to parse error message from response body
              errorMessage = "Failed to parse error message from response";
            }
          }
        } catch (e) {
          failureCount++;
        }
      }

      String resultMessage = "Messages sent: $successCount successful";
      if (failureCount > 0) {
        resultMessage += ", $failureCount failed";
      }
      return resultMessage;
    } catch (e) {
      throw Exception('Error sending messages: ${e.toString()}');
    }
  }

  // New method to pick and parse Excel file
  static Future<List<String>> pickAndParseExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        final bytes = result.files.first.bytes!;
        final excel = xl.Excel.decodeBytes(bytes);

        List<String> phoneNumbers = []; // List for phone numbers

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
                phoneNumbers.add(phone);
              }
            }
          }
        }
        return phoneNumbers;
      }
      return [];
    } catch (e) {
      throw Exception("Error processing Excel file: $e");
    }
  }

  // New method to fetch contacts from API
  static Future<List<String>> fetchContactsFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Define headers to address the 403 error
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Make API call to fetch contacts with headers
      final response = await http.get(
        Uri.parse('$baseUrl/api/contacts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> contactsJson = json.decode(response.body);

        // Extract phone numbers from contacts
        List<String> phoneNumbers = [];
        for (var contact in contactsJson) {
          String phone = contact['phoneNumber'] ?? '';
          if (phone.isNotEmpty) {
            phone = phone.replaceAll(' ', '');
            if (!phone.startsWith('+91')) {
              phone = '+91$phone';
            }
            phoneNumbers.add(phone);
          }
        }
        return phoneNumbers;
      } else {
        throw Exception(
          'Failed to load contacts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception("Error fetching contacts: $e");
    }
  }

  // New method to download Excel file
  static Future<String> downloadExcelFile() async {
    try {
      // Fetch all data from the table
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Define headers for the request
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/contacts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> tableData = json.decode(response.body);

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
          throw Exception('No data found in the table');
        }

        // Generate the Excel file bytes
        final bytes = excel.save();

        if (bytes != null) {
          // Get the file name with timestamp
          String fileName =
              'contacts-${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year}.xlsx';

          if (kIsWeb) {
            // For web platform
            final blob = html.Blob([Uint8List.fromList(bytes)]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.AnchorElement(href: url)
              ..setAttribute("download", fileName)
              ..click();
            html.Url.revokeObjectUrl(url);
            return "Excel file downloaded successfully";
          } else {
            // For mobile platforms
            // Create a temporary file in the app's documents directory
            final directory = await getApplicationDocumentsDirectory();
            final filePath = '${directory.path}/$fileName';

            final file = File(filePath);
            await file.writeAsBytes(bytes);

            return "Excel file saved to: $filePath";
          }
        } else {
          throw Exception('Failed to generate Excel file bytes');
        }
      } else {
        throw Exception(
          'Failed to fetch data from table: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception("Error downloading Excel file: ${e.toString()}");
    }
  }

  // Helper method to generate Excel from phone numbers if API call fails
  static Future<String> generateExcelFromPhoneNumbers(
    List<String> phoneNumbers,
  ) async {
    try {
      if (phoneNumbers.isEmpty) {
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
      for (int i = 0; i < phoneNumbers.length; i++) {
        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(phoneNumbers[i]);
      }

      // Generate the Excel file bytes
      final bytes = excel.save();

      if (bytes != null) {
        // Get the file name with timestamp
        String fileName =
            'phone_numbers-${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year}.xlsx';

        if (kIsWeb) {
          // For web platform
          final blob = html.Blob([Uint8List.fromList(bytes)]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
          return "Excel file downloaded successfully";
        } else {
          // For mobile platforms
          // Create a temporary file in the app's documents directory
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          return "Excel file saved to: $filePath";
        }
      } else {
        throw Exception('Failed to generate Excel file bytes');
      }
    } catch (e) {
      throw Exception("Error generating Excel file: ${e.toString()}");
    }
  }
}
