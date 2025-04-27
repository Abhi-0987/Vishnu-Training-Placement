import 'package:get/get.dart';
import '../services/whatsapp_services.dart';
import 'package:flutter/material.dart'; // Add this import for Colors

class AdminAttendanceController extends GetxController {
  final RxList<String> phoneNumbers = <String>[].obs;

  // Replace the single loading state with multiple states for different actions
  final RxBool isUploadingExcel = false.obs;
  final RxBool isFetchingContacts = false.obs;
  final RxBool isDownloadingExcel = false.obs;
  final RxBool isSendingMessages = false.obs;

  final RxString message = ''.obs;

  void setMessage(String value) {
    message.value = value;
  }

  void clearPhoneNumbers() {
    phoneNumbers.clear();
  }

  void addPhoneNumbers(List<String> numbers) {
    phoneNumbers.addAll(numbers);
  }

  Future<void> sendWhatsAppMessages() async {
    if (message.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (phoneNumbers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload a file with phone numbers first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      isSendingMessages.value = true;
      final response = await WhatsappServices.sendBulkMessages(
        phoneNumbers.toList(),
        message.value,
      );
      Get.snackbar(
        'Success',
        response,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSendingMessages.value = false;
    }
  }
}
