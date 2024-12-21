import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // Alias Firebase User
import '../models/user.dart' as app_models; // Alias your app's User model
import '../data/local/user_dao.dart';
import '../services/notifi_service.dart';
import 'event_list_screen.dart';
import 'authentication/login_screen.dart';
import 'pledged_gifts_screen.dart';
import 'my_pledged_gifts_screen.dart';
import 'user_information_screen.dart';

class ProfilePage extends StatefulWidget {
  final app_models.User user;



  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late app_models.User _currentUser;
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    notificationService = NotificationService();
    notificationService.initNotification();
  }

  Future<void> _logout() async {
    final bool confirm = await _showLogoutConfirmation();
    if (confirm) {
      await auth.FirebaseAuth.instance.signOut(); // Log out the user
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Dismiss dialog
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm logout
              child: Text("Yes"),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call logout function
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileImage(),
            SizedBox(height: 50), // Space between the image and buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    String genderImage = _currentUser.gender == 'Male'
        ? 'assets/male.webp'
        : 'assets/female.webp';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(genderImage), // Load the gender-based image
          onBackgroundImageError: (_, __) {
            print("Error loading profile image. Ensure the assets are properly configured.");
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserInformationScreen(user: _currentUser),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons to full width
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserInformationScreen(user: _currentUser),
                ),
              );
            },
            child: Text("User Information"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0), // Button height
              backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(height: 20), // Add space between buttons
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventListScreen(
                    userId: _currentUser.id,
                    currentUser: _currentUser,
                  ),
                ),
              );
            },
            child: Text("View My Events"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PledgedGiftsPage(userId: _currentUser.id),
                ),
              );
            },
            child: Text("View My Pledged Gifts"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              NotificationService()
                  .showNotification(title: 'Sample title', body: 'It works!');
              },
            child:Text("View My Notification"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blue,
              ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PledgedGiftsScreen(
                    userId: _currentUser.id,
                    notificationService: notificationService, // Pass the service
                  ),
                ),
              );
            },
            child: Text("View Gifts Pledged to Me"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
