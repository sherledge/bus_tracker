import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestPermissions() async {
    // Request locationWhenInUse first
    final locationWhenInUse = await Permission.locationWhenInUse.request();

    // If location is permanently denied, direct user to app settings
    if (locationWhenInUse.isPermanentlyDenied) {
      openAppSettings(); // Directs the user to app settings to manually enable the permission
      return false;
    }

    // If locationWhenInUse is not granted, return false
    if (!locationWhenInUse.isGranted) {
      return false;
    }

    // Introduce a delay if needed
    await Future.delayed(Duration(seconds: 1));

    // Request locationAlways after locationWhenInUse is granted
    final locationAlways = await Permission.locationAlways.request();

    // If locationAlways is permanently denied, direct to app settings
    if (locationAlways.isPermanentlyDenied) {
      openAppSettings(); // Directs the user to app settings to manually enable the permission
      return false;
    }

    // If locationAlways is not granted, return false
    if (!locationAlways.isGranted) {
      return false;
    }

    // Introduce another delay if needed
    await Future.delayed(Duration(seconds: 1));

    // Request ignoreBatteryOptimizations permission
    final batteryOptimizationPermission = await Permission.ignoreBatteryOptimizations.request();

    // If battery optimization permission is permanently denied, direct to app settings
    if (batteryOptimizationPermission.isPermanentlyDenied) {
      openAppSettings(); // Directs the user to app settings to manually enable the permission
      return false;
    }

    // Return true if all permissions are granted
    return locationAlways.isGranted && batteryOptimizationPermission.isGranted;
  }
}
