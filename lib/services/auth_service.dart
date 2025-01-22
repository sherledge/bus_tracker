import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get the email of the current user
  String? getUserEmail() {
    User? user = getCurrentUser();
    return user?.email;
  }

  // Get the bus ID from the current user's email
  String? getBusIdFromEmail() {
    String? email = getUserEmail();
    if (email != null) {
      return email.split('@')[0]; // Get the part before '@' as bus ID
    }
    return null;
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Handle error if sign-out fails
      print('Sign out error: $e');
    }
  }
}
