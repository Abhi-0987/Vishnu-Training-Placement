import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  static Future<List<String>> fetchAvailableDates() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print('Token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/student/dates'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add authorization header
      },
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load dates');
    }
  }

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

      if (result == null) {
        throw Exception("No file selected");
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw Exception("Failed to read file bytes");
      }

      final excel = xl.Excel.decodeBytes(bytes);
      List<String> phoneNumbers = [];

      final Set<String> normalizedKeywords = {
        "phone",
        "phonenumber",
        "parentsphone",
        "parentphone",
        "parentcontact",
        "parentscontact",
        "contactnumber",
        "mobilenumber",
        "mobile",
      };

      String normalize(String input) {
        return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      }

      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        int? phoneColumnIndex;

        if (sheet.rows.isEmpty || sheet.rows[0].isEmpty) {
          throw Exception("The sheet $tableName is empty or has no headers");
        }

        // Find the column index for phone number
        for (var i = 0; i < sheet.rows[0].length; i++) {
          final cellValue = sheet.rows[0][i]?.value?.toString() ?? "";
          final normalizedHeader = normalize(cellValue);

          if (normalizedKeywords.any(
            (keyword) => normalizedHeader.contains(keyword),
          )) {
            phoneColumnIndex = i;
            break;
          }
        }

        if (phoneColumnIndex == null) {
          throw Exception("Phone number column not found in sheet: $tableName");
        }

        // Extract phone numbers
        for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
          final row = sheet.rows[rowIndex];
          if (row.length > phoneColumnIndex) {
            final cellValue = row[phoneColumnIndex]?.value?.toString().trim();
            if (cellValue != null && cellValue.isNotEmpty) {
              String phone = cellValue.replaceAll(RegExp(r'\s+'), '');
              if (!phone.startsWith('+91')) {
                phone = '+91$phone';
              }
              phoneNumbers.add(phone);
            }
          }
        }
      }

      return phoneNumbers;
    } catch (e, stacktrace) {
      debugPrint("Error processing Excel file: $e");
      debugPrintStack(stackTrace: stacktrace);
      throw Exception("Error processing Excel file: $e");
    }
  }

  static Future<List<String>> fetchContactsByScheduleId(
    String scheduleId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/excel/absentees/json/bySchedule/$scheduleId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> contactsJson = json.decode(response.body);
        List<String> phoneNumbers = [];

        for (var contact in contactsJson) {
          String phone = contact.toString().replaceAll(' ', '');
          if (!phone.startsWith('+91')) {
            phone = '+91$phone';
          }
          phoneNumbers.add(phone);
        }
        return phoneNumbers;
      } else {
        throw Exception(
          'Failed to load contacts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception("Error fetching contacts by schedule ID: $e");
    }
  }

  static Future<List<String>> fetchContactsFromApi(selectedDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/excel/absentees/json/$selectedDate'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> contactsJson = json.decode(response.body);
        List<String> phoneNumbers = [];

        for (var contact in contactsJson) {
          String phone =
              contact.toString(); // No need for contact['phoneNumber']
          phone = phone.replaceAll(' ', '');
          if (!phone.startsWith('+91')) {
            phone = '+91$phone';
          }
          phoneNumbers.add(phone);
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

  static Future<String> downloadExcelFile(String selectedDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/excel/absentees/by-date/$selectedDate'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // ✅ Parse Excel bytes
        final excel = xl.Excel.decodeBytes(bytes);
        List<Map<String, String>> studentData = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;
          if (sheet.rows.isEmpty) continue;

          List<String> headersRow =
              sheet.rows[0].map((cell) {
                return cell?.value?.toString().toLowerCase().trim() ?? '';
              }).toList();

          int? nameIndex = headersRow.indexWhere(
            (h) => h.contains('name') && !h.contains('phone'),
          );
          int? emailIndex = headersRow.indexWhere((h) => h.contains('email'));
          int? phoneIndex = headersRow.indexWhere(
            (h) =>
                h.contains('phone') ||
                h.contains('contact') ||
                h.contains('mobile') ||
                h.contains('Phone number'),
          );

          for (int i = 1; i < sheet.rows.length; i++) {
            var row = sheet.rows[i];

            String name =
                (nameIndex < row.length)
                    ? row[nameIndex]?.value?.toString() ?? ''
                    : '';

            String email =
                (emailIndex < row.length)
                    ? row[emailIndex]?.value?.toString() ?? ''
                    : '';

            String phone =
                (phoneIndex < row.length)
                    ? row[phoneIndex]?.value?.toString() ?? ''
                    : '';

            studentData.add({
              'name': name,
              'email': email,
              'phoneNumber': phone,
            });
          }
        }

        // ✅ Print for verification (optional)
        for (var student in studentData) {
          print(
            "Name: ${student['name']}, Email: ${student['email']}, Phone: ${student['phoneNumber']}",
          );
        }

        // ✅ Save file (same as before)
        // ✅ Generate file name based on selectedDate
        final parsedDate = DateTime.parse(selectedDate);
        final fileName =
            'absentees-${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}.xlsx';

        if (kIsWeb) {
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
          return "Excel file downloaded successfully";
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          return "Excel file saved to: $filePath";
        }
      } else {
        throw Exception(
          'Failed to fetch Excel: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception("Error downloading Excel file: ${e.toString()}");
    }
  }

  static Future<String> downloadExcelByScheduleId(String scheduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/excel/by-schedule/absentees/$scheduleId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // ✅ Parse Excel bytes
        final excel = xl.Excel.decodeBytes(bytes);
        List<Map<String, String>> studentData = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;
          if (sheet.rows.isEmpty) continue;

          List<String> headersRow =
              sheet.rows[0].map((cell) {
                return cell?.value?.toString().toLowerCase().trim() ?? '';
              }).toList();

          int? nameIndex = headersRow.indexWhere(
            (h) => h.contains('name') && !h.contains('phone'),
          );
          int? emailIndex = headersRow.indexWhere((h) => h.contains('email'));
          int? phoneIndex = headersRow.indexWhere(
            (h) =>
                h.contains('phone') ||
                h.contains('contact') ||
                h.contains('mobile'),
          );

          for (int i = 1; i < sheet.rows.length; i++) {
            var row = sheet.rows[i];

            String name =
                (nameIndex < row.length)
                    ? row[nameIndex]?.value?.toString() ?? ''
                    : '';

            String email =
                (emailIndex < row.length)
                    ? row[emailIndex]?.value?.toString() ?? ''
                    : '';

            String phone =
                (phoneIndex < row.length)
                    ? row[phoneIndex]?.value?.toString() ?? ''
                    : '';

            studentData.add({
              'name': name,
              'email': email,
              'phoneNumber': phone,
            });
          }
        }

        for (var student in studentData) {
          print(
            "Name: ${student['name']}, Email: ${student['email']}, Phone: ${student['phoneNumber']}",
          );
        }

        // ✅ File name based on schedule ID
        final fileName = 'absentees-schedule-$scheduleId.xlsx';

        if (kIsWeb) {
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
          return "Excel file downloaded successfully";
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          return "Excel file saved to: $filePath";
        }
      } else {
        throw Exception(
          'Failed to fetch Excel: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(
        "Error downloading Excel file by schedule ID: ${e.toString()}",
      );
    }
  }

  static Future<String> generateExcelFromPhoneNumbers(
    List<String> phoneNumbers, {
    String? label, // optional, used in filename
  }) async {
    try {
      if (phoneNumbers.isEmpty) {
        throw Exception('No phone numbers available to export');
      }

      final excel = xl.Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet()!]!;

      // Add headers: Name | Email | Phone Number
      sheet.cell(xl.CellIndex.indexByString("A1")).value = xl.TextCellValue(
        'Name',
      );
      sheet.cell(xl.CellIndex.indexByString("B1")).value = xl.TextCellValue(
        'Email',
      );
      sheet.cell(xl.CellIndex.indexByString("C1")).value = xl.TextCellValue(
        'Phone Number',
      );

      // Apply header style
      for (var col = 0; col < 3; col++) {
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
            .cellStyle = xl.CellStyle(
          bold: true,
          horizontalAlign: xl.HorizontalAlign.Center,
        );
      }

      // Add rows
      for (int i = 0; i < phoneNumbers.length; i++) {
        // Split the string into parts (assuming "name - email - phone")
        List<String> parts = phoneNumbers[i].split(' - ');
        String name = parts.isNotEmpty ? parts[0] : '';
        String email = parts.length > 1 ? parts[1] : '';
        String phone = parts.length > 2 ? parts[2] : '';

        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(name);
        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(email);
        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(phone);
      }

      // Save the Excel file
      final bytes = excel.save();
      if (bytes != null) {
        final String timestamp = DateFormat(
          'yyyy-MM-dd_HHmmss',
        ).format(DateTime.now());
        String fileName =
            label != null ? 'contacts_$label.xlsx' : 'contacts_$timestamp.xlsx';

        if (kIsWeb) {
          final blob = html.Blob([Uint8List.fromList(bytes)]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
          return "Excel file downloaded successfully";
        } else {
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
