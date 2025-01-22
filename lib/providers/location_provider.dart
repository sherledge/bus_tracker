import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Position? _previousPosition;
  bool _isUpdating = false;
  Timer? _timer;
  String? _lastReportedStopName; // Track the last reported stop name
  bool _isReturning = false; // Track if the bus is returning
  bool get isUpdating => _isUpdating;
  Position? get currentPosition => _currentPosition;

  // Predefined list of bus stops with stop names
  List<Map<String, dynamic>> busStops = [
    {'name': 'Stop 1', 'latitude': 10.401869, 'longitude': 76.366382},
    {'name': 'Stop 2', 'latitude': 10.401868, 'longitude': 76.366381},
    {'name': 'stop 3', 'latitude': 12.976883, 'longitude': 77.601801},
    {'name': 'stop 4', 'latitude': 12.999290, 'longitude': 77.592673},
    {'name': 'stop 5', 'latitude': 12.985517, 'longitude': 77.555612},
    {'name': 'stop 6', 'latitude': 13.002649, 'longitude': 77.579985},
    {'name': 'stop 7', 'latitude': 12.943698, 'longitude': 77.590983},
    {'name': 'stop 8', 'latitude': 12.975574, 'longitude': 77.533768},
    {'name': 'stop 9', 'latitude': 13.4018104, 'longitude': 77.3664748},
    {'name': 'stop 10', 'latitude': 13.020393, 'longitude': 77.642643},
    // Add more stops as required
  ];

  // Proximity threshold (in meters)
  final double proximityThreshold = 50.0;

  // Start location updates every minute using Timer
  void startTracking(String busId) {
    _isUpdating = true;
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkLocationAndUpdate(busId);
    });
    notifyListeners();
  }

  // Stop tracking the bus
  void stopTracking() {
    _isUpdating = false;
    _timer?.cancel();
    _timer = null; // Ensure the timer is cleared
    notifyListeners();
  }

  // Method to update the bus status
  Future<void> updateBusStatus(String busId, String newStatus) async {
    await FirebaseFirestore.instance.collection('buses').doc(busId).update({
      'status': newStatus,
    });
    notifyListeners();
  }

  // Update the bus location with stop name if near a stop
  Future<void> _checkLocationAndUpdate(String busId) async {
    try {
      _previousPosition = _currentPosition;
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      var nearestStop = _findNearestStop(_currentPosition!);

      if (nearestStop != null) {
        String stopName = nearestStop['name']; // Get the stop name

        // Determine if the bus is returning
        if (_previousPosition != null) {
          var previousStop = _findNearestStop(_previousPosition!);
          _isReturning = _isBusReturning(previousStop, nearestStop);
        }

        // Only update Firestore if the stop has changed
        if (_previousPosition == null || _lastReportedStopName != stopName) {
          await FirebaseFirestore.instance.collection('buses').doc(busId).update({
            'stop_name': stopName,  // Update stop name in Firestore
            'timestamp': DateTime.now().toIso8601String(),
            'is_returning': _isReturning,  // Update return status in Firestore
          });

          _lastReportedStopName = stopName;  // Save the last reported stop
          print('Bus $busId reported at $stopName, returning: $_isReturning');
        } else {
          print('Already reported at stop $stopName');
        }
      } else {
        print('Not near any bus stop');
      }
    } catch (e) {
      // Add more specific error handling or retries if needed
      print('Error in updating location: $e');
    }
  }

  // Find the nearest stop based on proximity threshold
  Map<String, dynamic>? _findNearestStop(Position currentPosition) {
    double minDistance = double.infinity;
    Map<String, dynamic>? nearestStop;

    for (var stop in busStops) {
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        stop['latitude']!,
        stop['longitude']!,
      );

      // If the bus is within the proximity threshold, return the nearest stop
      if (distance <= proximityThreshold && distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
      }
    }
    return nearestStop;
  }

  // Determine if the bus is returning based on the previous and current stops
  bool _isBusReturning(Map<String, dynamic>? previousStop, Map<String, dynamic> currentStop) {
    if (previousStop == null) return false;

    int previousIndex = busStops.indexWhere((stop) => stop['name'] == previousStop['name']);
    int currentIndex = busStops.indexWhere((stop) => stop['name'] == currentStop['name']);

    return previousIndex > currentIndex;
  }
}
