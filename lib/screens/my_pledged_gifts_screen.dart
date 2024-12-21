import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../data/local/gift_dao.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userId; // Pass the user ID for filtering gifts

  PledgedGiftsPage({required this.userId});

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  List<Gift> pledgedGifts = [];
  final GiftDao _giftDao = GiftDao();

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  /// Loads pledged gifts for the logged-in user
  Future<void> _loadPledgedGifts() async {
    try {
      final gifts = await _giftDao.getMyPledgedGifts(widget.userId); // Use the pledger's ID
      setState(() {
        pledgedGifts = gifts;
      });
    } catch (e) {
      print("Error loading pledged gifts: $e");
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Pledged':
        return Colors.orange;
      case 'Purchased':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _editGift(Gift gift) {
    TextEditingController nameController = TextEditingController(text: gift.name);
    TextEditingController friendController = TextEditingController(text: gift.friendName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Pledged Gift"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Gift Name"),
                ),
                TextFormField(
                  controller: friendController,
                  decoration: InputDecoration(labelText: "Friend's Name"),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                gift.name = nameController.text;
                gift.friendName = friendController.text;
                await _giftDao.updateGift(gift, widget.userId);
                _loadPledgedGifts();
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGift(Gift gift) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Pledge"),
          content: Text("Are you sure you want to delete this pledge?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _giftDao.deleteGift(gift.id, widget.userId);
                _loadPledgedGifts();
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Pledged Gifts",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: pledgedGifts.isEmpty
          ? Center(
        child: Text(
          'No pledged gifts available.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: _getStatusColor(gift.status),
              ),
              title: Text(
                gift.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                'For: ${gift.friendName ?? 'Unknown'}\nDue: ${_formatDate(gift.dueDate)}',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: gift.isPending ?? false
                  ? Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editGift(gift),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGift(gift),
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }


}

//a5r version