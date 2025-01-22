import 'package:bus_tracker/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StopTrackingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Stop Tracking?'),
      content: Text('Are you sure you want to stop tracking the bus location?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false if user cancels
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            locationProvider.stopTracking();
            Navigator.of(context).pop(true); // Return true if tracking is stopped
          },
          child: Text('Stop'),
        ),
      ],
    );
  }
}
