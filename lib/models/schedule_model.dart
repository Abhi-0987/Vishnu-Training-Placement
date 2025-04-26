class Schedule {
  final String id;
  final String location;
  final String roomNo;
  final String date;
  final String time;
  final String studentBranch;
  
  Schedule({
    required this.id,
    required this.location,
    required this.roomNo,
    required this.date,
    required this.time,
    required this.studentBranch,

  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    String formattedTime = '';

    // Parse date array [YYYY, M, D]
    if (json['date'] is List && (json['date'] as List).length == 3) {
      try {
        List<dynamic> dateList = json['date'];
        int year = int.parse(dateList[0].toString());
        int month = int.parse(dateList[1].toString());
        int day = int.parse(dateList[2].toString());
        // Format to YYYY-MM-DD
        formattedDate = "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error parsing date list ${json['date']}: $e');
        formattedDate = json['date'].toString(); // Fallback
      }
    } else {
       formattedDate = json['date']?.toString() ?? ''; // Fallback if not a list
    }

    // Parse time array [H, M]
    if (json['time'] is List && (json['time'] as List).length == 2) {
      try {
        List<dynamic> timeList = json['time'];
        int hour = int.parse(timeList[0].toString());
        int minute = int.parse(timeList[1].toString());
        // Format to HH:mm (24-hour)
        formattedTime = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error parsing time list ${json['time']}: $e');
        formattedTime = json['time'].toString(); // Fallback
      }
    } else {
       formattedTime = json['time']?.toString() ?? ''; // Fallback if not a list
    }

    return Schedule(
      id: json['id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      roomNo: json['roomNo']?.toString() ?? '',
      date: formattedDate, // Use the formatted date string
      time: formattedTime, // Use the formatted time string
      studentBranch: json['studentBranch']?.toString() ?? '',
 // Add this line
    );
  }
  
  // Add this method to convert Schedule object to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'roomNo': roomNo,
      'date': date,
      'time': time,
      'studentBranch': studentBranch,
    };
  }
}