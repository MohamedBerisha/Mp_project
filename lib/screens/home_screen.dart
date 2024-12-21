import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/user.dart' as app_models;
import 'gift_list_screen.dart'; // Ensure this screen can accept a friendId and userId
import 'profile_screen.dart'; // Ensure ProfilePage accepts a User
import 'event_list_screen.dart'; // Ensure EventListScreen accepts friendId and userId
import '../data/local/friend_dao.dart';
import '../data/local/event_dao.dart'; // Add EventDao import
import 'create_event_screen.dart'; // Screen for creating a new event

class HomeScreen extends StatefulWidget {
  final app_models.User currentUser;

  HomeScreen({required this.currentUser});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Friend> friends = [];
  List<Friend> filteredFriends = [];
  final FriendDao _friendDao = FriendDao();
  final EventDao _eventDao = EventDao(); // Initialize EventDao
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final loadedFriends = await _friendDao.getFriends(widget.currentUser.id);

      for (var friend in loadedFriends) {
        // Fetch the count of upcoming events for each friend
        final eventCount = await _eventDao.getUpcomingEventCount(friend.id);

        // Update the friend object with the correct count
        friend.upcomingEvents = eventCount;
      }

      setState(() {
        friends = loadedFriends;
        _filterFriends(); // Update the filtered list
      });
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }


  void _filterFriends() {
    setState(() {
      filteredFriends = friends
          .where((friend) =>
          friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _showAddFriendDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
          ),
          title: Center(
            child: Text(
              'Add New Friend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Friend's Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Friend's Phone Number",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name and phone cannot be empty')),
                  );
                  return;
                }

                String friendPhone = phoneController.text.trim();
                String currentUserId = widget.currentUser.id;

                try {
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('phoneNumber', isEqualTo: friendPhone)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    final friendData = querySnapshot.docs.first.data();
                    final friendId = querySnapshot.docs.first.id;

                    // Add User B (friend) to User A's friend list
                    final newFriend = Friend(
                      id: friendId,
                      name: friendData['name'],
                      profileImage:
                      friendData['profileImage'] ?? 'assets/default.jpg',
                      upcomingEvents: 0,
                      phoneNumber: friendPhone,
                      userId: currentUserId,
                    );
                    await _friendDao.insertFriend(newFriend, currentUserId);

                    // Add User A (current user) to User B's friend list
                    final mutualFriend = Friend(
                      id: currentUserId,
                      name: widget.currentUser.name,
                      profileImage: widget.currentUser.profileImage ??
                          'assets/default.jpg',
                      upcomingEvents: 0,
                      phoneNumber: widget.currentUser.phoneNumber,
                      userId: friendId,
                    );
                    await _friendDao.insertFriend(mutualFriend, friendId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend added successfully')),
                    );

                    Navigator.of(context).pop();
                    await _fetchFriends();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend not found.')),
                    );
                  }
                } catch (e) {
                  print('Error adding friend: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add friend.')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }







  void _showEditFriendDialog(Friend friend) {
    final nameController = TextEditingController(text: friend.name);
    final phoneController = TextEditingController(text: friend.phoneNumber);
    final upcomingEventsController =
    TextEditingController(text: friend.upcomingEvents.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
          ),
          title: Center(
            child: Text(
              'Edit Friend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Friend's Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Friend's Phone Number",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: upcomingEventsController,
                    decoration: InputDecoration(
                      labelText: "Upcoming Events",
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final updatedFriend = friend.copyWith(
                  name: nameController.text,
                  phoneNumber: phoneController.text,
                  upcomingEvents:
                  int.tryParse(upcomingEventsController.text) ?? 0,
                );
                await _friendDao.updateFriend(
                    updatedFriend, widget.currentUser.id);
                Navigator.of(context).pop();
                await _fetchFriends();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _deleteFriend(Friend friend) async {
    await _friendDao.deleteFriend(friend.id, widget.currentUser.id);
    await _fetchFriends(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Home Page',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.currentUser),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add the Search Bar at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search friends...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _filterFriends();
                  });
                },
              ),
            ),
          ),

          // Keep existing buttons and other content unchanged
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateEventScreen(
                            currentUser: widget.currentUser,
                            onEventCreated: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EventListScreen(
                                    userId: widget.currentUser.id,
                                    currentUser: widget.currentUser,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.event),
                    label: Text("Create Your Own Event/List"),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventListScreen(
                          userId: widget.currentUser.id,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.list),
                  label: Text("View Event List"),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredFriends.isEmpty
                ? Center(child: Text('No friends found!'))
                : ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(friend.profileImage),
                  ),
                  title: Text(friend.name),
                  subtitle: Text("Upcoming Events: ${friend.upcomingEvents}"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventListScreen(
                          isFriendView: true,
                          friendId: friend.id,
                          userId: widget.currentUser.id,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditFriendDialog(friend),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFriend(friend),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddFriendDialog,
            icon: Icon(Icons.person_add),
            label: Text("Add Friend"),
          ),
        ],
      ),
    );
  }
}


//a5r version
