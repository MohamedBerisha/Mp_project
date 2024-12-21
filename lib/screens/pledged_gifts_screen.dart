import 'package:flutter/material.dart';
import '../data/local/gift_dao.dart';
import '../models/gift.dart';
import '../services/notifi_service.dart';

class PledgedGiftsScreen extends StatefulWidget {
  final String userId;
  final NotificationService notificationService;

  PledgedGiftsScreen({required this.userId, required this.notificationService});

  @override
  _PledgedGiftsScreenState createState() => _PledgedGiftsScreenState();
}

class _PledgedGiftsScreenState extends State<PledgedGiftsScreen> {
  final GiftDao _giftDao = GiftDao();
  List<Gift> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  /// Load pledged gifts from the database
  Future<void> _loadPledgedGifts() async {
    try {
      final gifts = await _giftDao.getPledgedGifts(widget.userId);
      setState(() {
        pledgedGifts = gifts;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading pledged gifts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Handles gift pledge logic and triggers a notification
  Future<void> pledgeGift(Gift gift, String userAName, String userBName) async {
    try {
      // Perform the logic to save the pledge
      print('Saving pledge for ${gift.name} from $userAName to $userBName');

      // Trigger local notification
      await widget.notificationService.showNotification(
        title: 'Gift Pledged!',
        body: 'You pledged "${gift.name}" for $userBName.',
      );

      print('Notification shown for pledging gift.');

      // Refresh the list of pledged gifts
      await _loadPledgedGifts();
    } catch (e) {
      print('Error pledging gift: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pledged Gifts Received",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : pledgedGifts.isEmpty
          ? Center(
        child: Text(
          "No pledged gifts yet!",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Icon(Icons.card_giftcard, color: Colors.orange, size: 40),
              title: Text(
                gift.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Pledged by: ${gift.friendName ?? 'Unknown'}",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          );
        },
      ),
    );
  }
}
