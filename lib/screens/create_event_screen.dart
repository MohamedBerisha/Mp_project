import 'package:flutter/material.dart';
import '../models/user.dart' as app_models;
import '../models/event.dart';
import '../data/local/event_dao.dart';
import 'event_list_screen.dart';

class CreateEventScreen extends StatefulWidget {
  final app_models.User currentUser; // Current logged-in user
  final VoidCallback onEventCreated; // Callback to notify event creation

  CreateEventScreen({required this.currentUser, required this.onEventCreated});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Controllers for text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _eventDate; // Variable to hold the selected event date
  String? _selectedCategory; // Variable for storing the selected category

  final List<String> _categories = [
    "Birthday",
    "Anniversary",
    "Corporate",
    "Wedding",
    "General",
  ]; // Predefined event categories

  // Function to handle date selection
  void _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _eventDate = pickedDate; // Update the selected event date
      });
    }
  }

  // Function to validate inputs and save the event
  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _eventDate == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      final eventDao = EventDao();
      final newEvent = Events(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        date: _eventDate!.toIso8601String(), // ISO format for the date
        imageUrl: null, // No image URL
        userId: widget.currentUser.id, // Associate with the current user
        category: _selectedCategory!, // Selected category
        status: "Upcoming",
      );

      await eventDao.insertEvent(newEvent); // Insert the event into the database

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event created successfully!")),
      );

      // Navigate to EventListScreen and pass the user details
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EventListScreen(
            userId: widget.currentUser.id,
            currentUser: widget.currentUser, // Pass the current user object
          ),
        ),
      );
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event. Please try again.")),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Event",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title
            Center(
              child: Text(
                "Create Event",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            SizedBox(height: 20),

            // Event Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Event Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Event Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Event Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Event Location
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Date Picker
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                _eventDate == null
                    ? "Select Event Date"
                    : "Event Date: ${_eventDate!.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),

            // Create Event Button
            Center(
              child: ElevatedButton(
                onPressed: _saveEvent,
                child: Text(
                  "Create Event",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}