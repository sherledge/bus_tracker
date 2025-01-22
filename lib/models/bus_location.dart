class BusLocation {
  final double latitude;
  final double longitude;
  final String busId;
  final DateTime timestamp;
  String status; // New status field

  BusLocation({
    required this.latitude,
    required this.longitude,
    required this.busId,
    required this.timestamp,
  this.status='active',  // New parameter
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'busId': busId,
        'timestamp': timestamp.toIso8601String(),
        'status': status, // Serialize the status
      };
}
