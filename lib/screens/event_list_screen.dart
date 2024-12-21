import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart' as app_models; // Use alias for User model
import '../widgets/event_tile.dart';
import '../data/local/event_dao.dart';
import 'create_event_screen.dart';

class EventListScreen extends StatefulWidget {
  final bool isFriendView;
  final String? friendId;
  final String userId;
  final app_models.User currentUser; // Added currentUser property

  EventListScreen({
    required this.userId,
    required this.currentUser, // Initialize currentUser
    this.isFriendView = false,
    this.friendId,
  });

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Events> events = [];
  final EventDao _eventDao = EventDao();
  String sortCriteria = 'Name';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<Events> loadedEvents;
    print("Viewing events for friend: ${widget.friendId}");

    if (widget.isFriendView && widget.friendId != null) {
      // Fetch events for the friend's userId
      loadedEvents = await _eventDao.getEventsForUser(widget.friendId!);
    } else {
      // Fetch events for the current userId
      loadedEvents = await _eventDao.getEventsForUser(widget.userId);
    }

    setState(() {
      events = _sortEvents(loadedEvents);
    });
  }

  List<Events> _sortEvents(List<Events> events) {
    switch (sortCriteria) {
      case 'Category':
        events.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Status':
        events.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'Name':
      default:
        events.sort((a, b) => a.name.compareTo(b.name));
    }
    return events;
  }

  void _showAddOrEditEventDialog({Events? event}) {
    final TextEditingController nameController =
    TextEditingController(text: event?.name ?? '');
    final TextEditingController categoryController =
    TextEditingController(text: event?.category ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: event?.description ?? '');
    final TextEditingController locationController =
    TextEditingController(text: event?.location ?? '');
    final TextEditingController dateController =
    TextEditingController(text: event?.date ?? '');
    String selectedStatus = event?.status ?? 'Upcoming';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event == null ? 'Add New Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledInputField(
                      controller: nameController, label: "Event Name"),
                  SizedBox(height: 16),
                  _buildStyledInputField(
                      controller: categoryController, label: "Category"),
                  SizedBox(height: 16),
                  _buildStyledInputField(
                      controller: descriptionController, label: "Description"),
                  SizedBox(height: 16),
                  _buildStyledInputField(
                      controller: locationController, label: "Location"),
                  SizedBox(height: 16),
                  _buildStyledInputField(
                      controller: dateController, label: "Date"),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                      });
                    },
                    items: ['Upcoming', 'Current', 'Past'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newEvent = Events(
                  id: event?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  category: categoryController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  date: dateController.text,
                  status: selectedStatus,
                  userId: widget.userId,
                );
                if (event == null) {
                  await _eventDao.insertEvent(newEvent);
                } else {
                  await _eventDao.updateEvent(newEvent);
                }
                _loadEvents();
                Navigator.pop(context);
              },
              child: Text(event == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyledInputField(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _showDeleteConfirmation(Events event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _eventDao.deleteEvent(event.id, widget.userId);
                _loadEvents();
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFriendView ? 'Friend\'s Events' : 'My Events'),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: sortCriteria,
            underline: SizedBox(),
            dropdownColor: Colors.blue[50],
            onChanged: (String? newCriteria) {
              setState(() {
                sortCriteria = newCriteria!;
                events = _sortEvents(events);
              });
            },
            items: ['Name', 'Category', 'Status'].map((criteria) {
              return DropdownMenuItem(
                value: criteria,
                child: Text(
                  criteria,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(
        child: Text(
          'No events found!',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: EventTile(
              event: event,
              userId: widget.userId,
              isFriendView: widget.isFriendView,
              onEdit: widget.isFriendView
                  ? null
                  : (event) => _showAddOrEditEventDialog(event: event),
              onDelete: widget.isFriendView
                  ? null
                  : () => _showDeleteConfirmation(event),
            ),
          );
        },
      ),
      floatingActionButton: widget.isFriendView
          ? null
          : FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(
                currentUser: widget.currentUser,
                onEventCreated: _loadEvents,
              ),
            ),
          );
        },
        tooltip: 'Add Event',
        child: Icon(Icons.add),
      ),
    );
  }
}
