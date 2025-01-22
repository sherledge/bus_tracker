import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';
@override
void initState() {
  super.initState();
  _checkLoginStatus();
}

Future<void> _checkLoginStatus() async {
  _auth.authStateChanges().listen((User? user) {
    if (user != null) {
      // User is logged in, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  });
}

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    String pattern =
        r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+'; // Simple regex pattern for email
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bus Tracker Companion', style: TextStyle(fontFamily: 'Coda', fontSize: 32)),
        elevation: 0, // No elevation for the AppBar
        backgroundColor: Colors.transparent, // Transparent background
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cool divider
            Container(
              height: 2,
              color: Colors.grey[300],
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            ),
            SizedBox(height: 200),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: _emailValidator,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: _passwordValidator,
                    ),
                    SizedBox(height: 20),
                      SizedBox(
                      width: 300, // Set the width of the button
                      height: 40, // Set the height of the button
                      child: OutlinedButton(
                        onPressed: _login,
                        child: Text('Login', style: TextStyle(fontFamily: 'Coda', fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.black, width: 1), // Border color and width
                          backgroundColor: Color(0xFF77E5A4), // Background color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Curved edges with radius of 8
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
