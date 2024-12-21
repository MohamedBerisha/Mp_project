import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/local/friend_dao.dart';
import '../../models/friend.dart';
import '../../models/user.dart' as app_models;
import '../home_screen.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {

  final String? userId; // Add this field

  LoginScreen({this.userId}); // Add this constructor

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  bool isLoading = false;

  /// Handles the login process
  /// Handles the login process
  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both email and password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      auth.UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user!.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final app_models.User currentUser = app_models.User(
          id: userId,
          name: userDoc['name'] ?? '',
          email: userDoc['email'] ?? '',
          phoneNumber: userDoc['phoneNumber'] ?? '',
          dateOfBirth: DateTime.parse(userDoc['dateOfBirth']),
          gender: userDoc['gender'] ?? '',
          address: userDoc['address'] ?? '',
          profileImage: userDoc['profileImage'],
        );

        // Fetch existing friends from Firestore
        QuerySnapshot friendDocs = await FirebaseFirestore.instance
            .collection('friendships')
            .doc(userId)
            .collection('friends')
            .get();

        List<Friend> currentFriends = friendDocs.docs.map((doc) {
          return Friend(
            id: doc.id,
            name: doc['name'],
            phoneNumber: doc['phoneNumber'],
            profileImage: doc['profileImage'] ?? 'assets/default.jpg',
            upcomingEvents: 0, // Placeholder; update this logic as needed
            userId: userId,
          );
        }).toList();

        // Add mutual friendships for any missing ones
        for (final friend in currentFriends) {
          final DocumentSnapshot friendDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(friend.id)
              .get();

          if (friendDoc.exists) {
            final mutualFriend = Friend(
              id: currentUser.id,
              name: currentUser.name,
              phoneNumber: currentUser.phoneNumber,
              profileImage: currentUser.profileImage ?? 'assets/default.jpg',
              upcomingEvents: 0, // Placeholder
              userId: friend.id,
            );

            // Check if mutual friendship exists; if not, add it
            final mutualFriendDoc = await FirebaseFirestore.instance
                .collection('friendships')
                .doc(friend.id)
                .collection('friends')
                .doc(currentUser.id)
                .get();

            if (!mutualFriendDoc.exists) {
              await FirebaseFirestore.instance
                  .collection('friendships')
                  .doc(friend.id)
                  .collection('friends')
                  .doc(currentUser.id)
                  .set(mutualFriend.toMap());
            }
          }
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeScreen(currentUser: currentUser),
          ),
              (Route<dynamic> route) => false,
        );
        print('Navigated to HomeScreen');

      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage('The supplied auth credential is incorrect, malformed, or expired.');
    }
  }




  /// Displays a snackbar with a message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              // Gift Image
              Center(
                child: Image.asset(
                  'assets/welcome.webp', // Replace with your gift image path
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 20), // Move image slightly lower
              // Title
              Text(
                'Welcome to Hedieaty App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Blue title
                ),
              ),
              SizedBox(height: 25),

              // Email TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  key: Key('emailField'),
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Password TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  key: Key('passwordField'),
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 25), // Space between Password and Login button
              // Login Button
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                key: Key('loginButton'), // Add a unique key
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              // Signup Link
              GestureDetector(
                key: Key("Don't have an account?Signup here"),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => SignupScreen())),
                child: Text(
                  "Don't have an account? Signup here",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
