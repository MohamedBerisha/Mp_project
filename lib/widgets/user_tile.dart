import 'package:flutter/material.dart';
import '../models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // Optional delete functionality

  UserTile({required this.user, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profileImage != null
            ? NetworkImage(user.profileImage!)
            : AssetImage('assets/default_user.png') as ImageProvider,
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      onTap: onTap,
      trailing: onDelete != null
          ? IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      )
          : null,
    );
  }
}
