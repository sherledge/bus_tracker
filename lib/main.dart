import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_tracker/core/permissions_service.dart';
import 'package:bus_tracker/screens/login_screen.dart';
import 'package:bus_tracker/providers/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyD-25ieHTC9YF20E1UkQ5bdxK5Vn_RPqqQ',
      appId: '1:1054402456638:android:91efb96b3aeb5e7df1f56f',
      messagingSenderId: '1054402456638',
      projectId: 'bus-tracker-a57b9',
      storageBucket: 'bus-tracker-a57b9.appspot.com',
    ),
  );

  // Request permissions
  bool hasPermissions = await PermissionsService.requestPermissions();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        // Add other providers here if needed
      ],
      child: MyApp(hasPermissions: hasPermissions),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasPermissions;

  MyApp({this.hasPermissions = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),
      home: hasPermissions ? LoginScreen() : PermissionDeniedScreen(),
    );
  }
}

class PermissionDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Permission Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Permissions are required to use this app.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Retry requesting permissions
                bool granted = await PermissionsService.requestPermissions();
                if (granted) {
                  // Navigate to LoginScreen if permissions are granted
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              child: Text('Grant Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
