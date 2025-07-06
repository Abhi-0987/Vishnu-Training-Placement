import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vishnu_training_and_placements/services/whatsapp_services.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/screens_background.dart';
import 'package:get/get.dart';
import '../controllers/admin_attendance_controller.dart';

class AdminMarkAttendence extends StatefulWidget {
  final int? scheduleId;
  const AdminMarkAttendence({super.key, this.scheduleId});

  @override
  State<AdminMarkAttendence> createState() => _AdminMarkAttendenceState();
}

class _AdminMarkAttendenceState extends State<AdminMarkAttendence> {
  final AdminAttendanceController controller = Get.put(
    AdminAttendanceController(),
  );
  final TextEditingController _messageController = TextEditingController();
  List<String> availableDates = [];
  String? selectedDate;
  bool isLoadingDates = false;
  DateTime? scheduleDateFromPicker;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.scheduleId != null) {
      fetchContactsfromApi(); // Fetch by scheduleId directly
    }
  }

  Future<void> pickExcelFile() async {
    try {
      controller.isUploadingExcel.value = true;

      List<String> newPhoneNumbers =
          await WhatsappServices.pickAndParseExcelFile();

      setState(() {
        controller.clearPhoneNumbers();
        controller.addPhoneNumbers(newPhoneNumbers);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Loaded ${newPhoneNumbers.length} phone numbers"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing file: ${e.toString()}")),
      );
    } finally {
      controller.isUploadingExcel.value = false;
    }
  }

  Future<void> fetchAvailableDates() async {
    setState(() {
      isLoadingDates = true;
    });

    try {
      final response = await WhatsappServices.fetchAvailableDates();

      if (response.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No dates available")));
        return;
      }

      // Convert to DateTime, filter <= today, remove duplicates
      Set<DateTime> uniqueDates =
          response
              .map((dateStr) => DateTime.parse(dateStr))
              .where(
                (d) =>
                    d.isBefore(DateTime.now()) || isSameDate(d, DateTime.now()),
              )
              .toSet();

      List<DateTime> sortedDates =
          uniqueDates.toList()..sort((a, b) => b.compareTo(a)); // Descending

      if (sortedDates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No past dates available")),
        );
        return;
      }

      DateTime initialDate = sortedDates.first;

      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
        selectableDayPredicate: (DateTime day) {
          return uniqueDates.any((d) => isSameDate(d, day));
        },
      );

      if (pickedDate != null) {
        setState(() {
          scheduleDateFromPicker = pickedDate;
          selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Selected date: $selectedDate")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching dates: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoadingDates = false;
      });
    }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void showDateSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select a Date"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  return ListTile(
                    title: Text(date),
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  Future<void> fetchContactsfromApi() async {
    try {
      controller.isFetchingContacts.value = true;

      List<String> newPhoneNumbers = [];

      if (widget.scheduleId != null) {
        // Case 1: Fetch using schedule ID
        newPhoneNumbers = await WhatsappServices.fetchContactsByScheduleId(
          widget.scheduleId!.toString(),
        );
      } else if (scheduleDateFromPicker != null) {
        // Case 2: Fetch using selected date
        String formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(scheduleDateFromPicker!);
        newPhoneNumbers = await WhatsappServices.fetchContactsFromApi(
          formattedDate,
        );
      } else {
        _showSnackbar(
          "Please select a date or provide a schedule ID",
          Colors.orange,
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        controller.clearPhoneNumbers();
        controller.addPhoneNumbers(newPhoneNumbers);
      });

      _showSnackbar(
        "Fetched ${newPhoneNumbers.length} contacts from API",
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackbar("Error fetching contacts: ${e.toString()}", Colors.red);
    } finally {
      controller.isFetchingContacts.value = false;
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> downloadExcelFile() async {
    if (widget.scheduleId == null && selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please provide either a Schedule ID or select a date.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      controller.isDownloadingExcel.value = true;

      String result;

      // 🔹 Primary Case 1: Download by scheduleId
      if (widget.scheduleId != null) {
        result = await WhatsappServices.downloadExcelByScheduleId(
          widget.scheduleId!.toString(),
        );
      }
      // 🔹 Primary Case 2: Download by selectedDate
      else {
        result = await WhatsappServices.downloadExcelFile(selectedDate!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading Excel file: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      // 🔁 Fallback: Generate Excel from memory
      try {
        final String? label =
            selectedDate ??
            (widget.scheduleId != null
                ? "schedule_${widget.scheduleId}"
                : null);

        String result = await WhatsappServices.generateExcelFromPhoneNumbers(
          controller.phoneNumbers.toList(),
          label: label,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.green),
        );
      } catch (fallbackError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Fallback Excel generation failed: ${fallbackError.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      controller.isDownloadingExcel.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstants.textBlack,
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
                              color: AppConstants.textWhite,
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
                                      color: AppConstants.textWhite,
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
                                          backgroundColor:
                                              AppConstants.primaryColor,
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
                                                color: AppConstants.textWhite,
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
                                      const SizedBox(height: 10),

                                      if (widget.scheduleId == null)
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                          ),
                                          onPressed:
                                              isLoadingDates
                                                  ? null
                                                  : fetchAvailableDates,
                                          icon: const Icon(
                                            Icons.date_range,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            selectedDate == null
                                                ? "Select Date"
                                                : "Selected: ${DateFormat('dd MMM yyyy').format(DateTime.parse(selectedDate!))}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Alata',
                                            ),
                                          ),
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
                                                    fetchContactsfromApi();
                                                  },
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                controller
                                                        .isFetchingContacts
                                                        .value
                                                    ? "Fetching..."
                                                    : "Fetch Absentees",
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
                                                  color: AppConstants.textWhite,
                                                  fontSize: 16,
                                                  fontFamily: 'Alata',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.download,
                                                color: AppConstants.textWhite,
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
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppConstants.textWhite,
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
                                                    color:
                                                        AppConstants.textWhite,
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
                                  backgroundColor: AppConstants.primaryColor,
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
                                                await WhatsappServices.sendBulkMessages(
                                                  controller.phoneNumbers
                                                      .toList(),
                                                  controller.message.value,
                                                );

                                            if (!mounted) return;
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
                                            if (!mounted) return;
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
                                        color: AppConstants.textWhite,
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
