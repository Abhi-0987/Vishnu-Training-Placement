class Venue {
  final int id;
  final String blockName;
  final String roomNumber;
  final double latitude;
  final double longitude;

  Venue({
    required this.id,
    required this.blockName,
    required this.roomNumber,
    required this.latitude,
    required this.longitude,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      blockName: json['blockName'],
      roomNumber: json['roomNumber'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
