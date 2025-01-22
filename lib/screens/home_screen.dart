import 'package:bus_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'stop_tracking_dialog.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTracking = false;
  String _busStatus = "active"; // Default bus status
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      _updateTracking(locationProvider);
    });
  }

  void _updateTracking(LocationProvider locationProvider) {
    String? busId = _authService.getBusIdFromEmail();

    if (_busStatus == 'active' && !_isTracking) {
      locationProvider.startTracking(busId!);
      setState(() {
        _isTracking = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tracking started')),
      );
    } else if (_busStatus != 'active' && _isTracking) {
      locationProvider.stopTracking();
      setState(() {
        _isTracking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tracking stopped')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    String? busId = _authService.getBusIdFromEmail();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Bus Tracker Companion',
          style: TextStyle(fontFamily: 'coda'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => StopTrackingDialog(),
              );

              if (result == true) {
                locationProvider.stopTracking();
                setState(() {
                  _isTracking = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tracking stopped')),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF77E5A4),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout', style: TextStyle(fontFamily: 'Coda')),
              onTap: () async {
                await _logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Indicator
            Container(
              height: 400,
              width: 700,
              child: Image.asset('assets/images/bus.png'),
            ),
            Center(
              child: Text(
                _isTracking ? 'Tracking is Active' : 'Tracking is Inactive',
                style: TextStyle(
                  fontFamily: 'coda',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isTracking ? Colors.green : Colors.red,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Instructions
            Center(
              child: Text(
                'Select the bus status and manage tracking',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[700], fontFamily: 'coda'),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 86.0),
              child: DropdownButton<String>(
                isExpanded: true, // Make the dropdown take full width
                value: _busStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    _busStatus = newValue!;
                  });
                  locationProvider.updateBusStatus(busId!, _busStatus);
                  _updateTracking(locationProvider);
                },
                items: <String>[
                  'active',
                  'maintenance',
                  'service',
                  'out of service'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          value == 'active'
                              ? Icons.directions_bus
                              : value == 'maintenance'
                                  ? Icons.build
                                  : value == 'service'
                                      ? Icons.local_activity
                                      : Icons.cancel,
                          color: value == 'active'
                              ? Colors.green
                              : value == 'maintenance'
                                  ? Colors.orange
                                  : value == 'service'
                                      ? Colors.blue
                                      : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(value, style: TextStyle(fontFamily: 'Coda')),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Button for restarting tracking if it was stopped
            !_isTracking
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_busStatus == 'active') {
                        locationProvider.startTracking(busId!);
                        setState(() {
                          _isTracking = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tracking started again')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bus is not active')),
                        );
                      }
                    },
                    child: Text('Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Color(0xFF77E5A4), // Button color
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
