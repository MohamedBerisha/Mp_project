import 'package:flutter/material.dart';
import '../models/gift.dart'; // Correct import path for Gift model

class GiftTile extends StatelessWidget {
  final Gift gift; // Required gift model
  final VoidCallback? onEdit; // Optional callback for editing
  final VoidCallback? onDelete; // Optional callback for deletion
  final VoidCallback? onPledge; // Optional callback for pledging a gift

  GiftTile({
    required this.gift,
    this.onEdit,
    this.onDelete,
    this.onPledge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(gift.status), // Dynamic color based on status
      ),
      title: Text(gift.name), // Gift name
      subtitle: Text('${gift.category} - ${gift.status}'), // Gift details
      trailing: Wrap(
        spacing: 8,
        children: [
          // Edit button
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
          // Delete button
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          // Pledge button (only if gift is available)
          //if (onPledge != null && gift.status == 'Available')
            /*IconButton(
              icon: Icon(Icons.volunteer_activism),
              color: Colors.blue,
              tooltip: 'Pledge Gift',
              onPressed: onPledge,
            ),*/
        ],
      ),
    );
  }

  // Determines the background color based on gift status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Pledged':
        return Colors.orange;
      case 'Purchased':
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}
