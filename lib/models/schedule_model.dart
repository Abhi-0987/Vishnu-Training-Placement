class Schedule {
  final String id;
  final String location;
  final String roomNo;
  final String date;
  final String fromTime;
  final String toTime;
  final String studentBranch;
  final bool mark;

  Schedule({
    required this.id,
    required this.location,
    required this.roomNo,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.studentBranch,
    required this.mark,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    String formattedFromTime = '';
    String formattedToTime = '';

    // Parse date array [YYYY, M, D]
    if (json['date'] is List && (json['date'] as List).length == 3) {
      try {
        List<dynamic> dateList = json['date'];
        int year = int.parse(dateList[0].toString());
        int month = int.parse(dateList[1].toString());
        int day = int.parse(dateList[2].toString());
        // Format to YYYY-MM-DD
        formattedDate =
            "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error parsing date list ${json['date']}: $e');
        formattedDate = json['date'].toString(); // Fallback
      }
    } else {
      formattedDate = json['date']?.toString() ?? ''; // Fallback if not a list
    }

    // Parse fromTime array [H, M]
    if (json['fromTime'] is List && (json['fromTime'] as List).length == 2) {
      try {
        List<dynamic> timeList = json['fromTime'];
        int hour = int.parse(timeList[0].toString());
        int minute = int.parse(timeList[1].toString());
        // Format to HH:mm (24-hour)
        formattedFromTime =
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error parsing fromTime list ${json['fromTime']}: $e');
        formattedFromTime = json['fromTime'].toString(); // Fallback
      }
    } else {
      formattedFromTime =
          json['fromTime']?.toString() ?? ''; // Fallback if not a list
    }

    // Parse toTime array [H, M]
    if (json['toTime'] is List && (json['toTime'] as List).length == 2) {
      try {
        List<dynamic> timeList = json['toTime'];
        int hour = int.parse(timeList[0].toString());
        int minute = int.parse(timeList[1].toString());
        // Format to HH:mm (24-hour)
        formattedToTime =
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error parsing toTime list ${json['toTime']}: $e');
        formattedToTime = json['toTime'].toString(); // Fallback
      }
    } else {
      formattedToTime =
          json['toTime']?.toString() ?? ''; // Fallback if not a list
    }

    return Schedule(
      id: json['id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      roomNo: json['roomNo']?.toString() ?? '',
      date: formattedDate, // Use the formatted date string
      fromTime: formattedFromTime, // Use the formatted fromTime string
      toTime: formattedToTime, // Use the formatted toTime string
      studentBranch: json['studentBranch']?.toString() ?? '',
      mark: json['mark'] ?? false,
    );
  }

  // Add this method to convert Schedule object to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'roomNo': roomNo,
      'date': date,
      'fromTime': fromTime,
      'toTime': toTime,
      'studentBranch': studentBranch,
      'mark': mark,
    };
  }

  bool isOver() {
    try {
      final dateParts = date.split('-');
      final timeParts = toTime.split(':');

      if (dateParts.length == 3 && timeParts.length == 2) {
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final scheduleEnd = DateTime(year, month, day, hour, minute);
        return DateTime.now().isAfter(scheduleEnd);
      }
    } catch (e) {
      print('Error checking schedule end time: $e');
    }
    return false; // fallback
  }
}
