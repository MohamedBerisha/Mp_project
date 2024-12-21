import 'package:flutter/material.dart';
import '../models/event.dart';
import '../screens/gift_list_screen.dart';

class EventTile extends StatelessWidget {
  final Events event;
  final String userId;
  final Function(Events)? onEdit; // Optional for conditional behavior
  final VoidCallback? onDelete; // Optional for conditional behavior
  final bool isFriendView; // Add this to determine view mode

  EventTile({
    required this.event,
    required this.userId,
    this.onEdit, // Make it optional
    this.onDelete, // Make it optional
    this.isFriendView = false, // Defaults to false
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: event.imageUrl != null && event.imageUrl!.isNotEmpty
          ? CircleAvatar(
        backgroundImage: NetworkImage(event.imageUrl!),
      )
          : CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(event.name[0]), // Display first letter of the event name
      ),
      title: Text(event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${event.category} - ${event.status}'),
          if (event.description != null && event.description!.isNotEmpty)
            Text(
              'Description: ${event.description}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (event.location != null && event.location!.isNotEmpty)
            Text(
              'Location: ${event.location}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (event.date != null && event.date!.isNotEmpty)
            Text(
              'Date: ${event.date}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GiftListScreen(
              eventId: event.id,
              userId: userId,
              isFriendView: isFriendView,
            ),
          ),
        );
      },
      // Conditionally show the edit/delete icons
      trailing: isFriendView
          ? null // No icons for friend's events
          : Wrap(
        spacing: 8,
        children: [
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => onEdit!(event),
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
