import 'package:get/get.dart';
import '../services/api_services.dart';

class AdminAttendanceController extends GetxController {
  final RxList<String> phoneNumbers = <String>[].obs;
  final RxBool isLoading = false.obs;
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
      );
      return;
    }

    if (phoneNumbers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload a file with phone numbers first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await ApiService.sendBulkMessages(
        phoneNumbers.toList(),
        message.value,
      );
      Get.snackbar('Success', response, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
