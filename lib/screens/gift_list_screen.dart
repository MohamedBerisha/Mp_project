import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../screens/gift_details_screen.dart';
import '../widgets/gift_tile.dart';
import '../data/local/gift_dao.dart';

class GiftListScreen extends StatefulWidget {
  final String eventId;
  final String userId; // User ID for filtering gifts
  final bool isFriendView;

  GiftListScreen({
    required this.eventId,
    required this.userId,
    this.isFriendView = false,
  });

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftDao _giftDao = GiftDao();
  List<Gift> gifts = [];
  String sortCriteria = 'Name';

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    try {
      List<Gift> loadedGifts;

      if (widget.isFriendView) {
        // Fetch all gifts for the friend's event (without filtering by userId)
        print("Fetching gifts for friend's event: ${widget.eventId}");
        loadedGifts = await _giftDao.getGiftsForEventWithoutUserId(widget.eventId);
      } else {
        // Fetch gifts for the current user's event
        print("Fetching gifts for user's event: ${widget.eventId}, userId: ${widget.userId}");
        loadedGifts = await _giftDao.getGiftsForEvent(widget.eventId, widget.userId);
      }

      setState(() {
        gifts = _sortGifts(loadedGifts); // Optionally sort the gifts
      });

      print("Loaded gifts: ${gifts.map((gift) => gift.toMap()).toList()}");
    } catch (e) {
      print('Error loading gifts: $e');
    }
  }





  List<Gift> _sortGifts(List<Gift> gifts) {
    switch (sortCriteria) {
      case 'Category':
        gifts.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Status':
        gifts.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'Name':
      default:
        gifts.sort((a, b) => a.name.compareTo(b.name));
    }
    return gifts;
  }

  void _showAddOrEditGiftDialog({Gift? gift}) {
    TextEditingController nameController = TextEditingController(text: gift?.name ?? '');
    TextEditingController categoryController = TextEditingController(text: gift?.category ?? '');
    TextEditingController priceController = TextEditingController(text: gift?.price?.toString() ?? '');
    String imagePath = gift?.imagePath ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add New Gift' : 'Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (value) {
                    setState(() {
                      imagePath = _getImageForCategory(value.trim().toLowerCase());
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                imagePath.isNotEmpty
                    ? Image.asset(
                  imagePath,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : SizedBox(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                final newGift = Gift(
                  id: gift?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  price: double.tryParse(priceController.text.trim()) ?? 0.0,
                  imagePath: imagePath,
                  status: 'Available',
                  eventID: widget.eventId,
                  userId: widget.userId,
                );

                try {
                  if (gift == null) {
                    await _giftDao.insertGift(newGift);
                  } else {
                    await _giftDao.updateGift(newGift, widget.userId);
                  }
                  _loadGifts();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error saving gift: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving gift.')),
                  );
                }
              },
              child: Text(gift == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  /// Returns the image path based on the category
  String _getImageForCategory(String category) {
    const categoryImageMap = {
      'airpods': 'assets/airpods.webp',
      'alarm': 'assets/alarm.webp',
      'bag': 'assets/bag.webp',
      'bottle': 'assets/bottle.webp',
      'book': 'assets/book.webp',
      'candle': 'assets/candle.webp',
      'camera': 'assets/camera.webp',
      'cap': 'assets/cap.webp',
      'car': 'assets/car.webp',
      'cup': 'assets/cup.webp',
      'headphone': 'assets/headphone.webp',
      'heel': 'assets/heel.webp',
      'ipad': 'assets/ipad.webp',
      'lamp': 'assets/lamp.webp',
      'laptop': 'assets/laptop.webp',
      'phone': 'assets/phone.webp',
      'shoe': 'assets/shoe.webp',
      'sunglasses': 'assets/sunglasses.webp',
      'trouser': 'assets/trouser.webp',
      'tshirt': 'assets/tshirt.webp',
      'vase': 'assets/vase.webp',
      'wallet': 'assets/wallet.webp',
      'watch': 'assets/watch.webp',
    };

    return categoryImageMap[category] ?? '';
  }

  Color _getGiftColor(String status) {
    switch (status) {
      case 'Pledged':
        return Colors.orange;
      case 'Purchased':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  void _pledgeGift(Gift gift) async {
    if (gift.status != 'Available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("This gift is already pledged or purchased.")),
      );
      return;
    }

    // Create the pledged gift object
    final pledgedGift = gift.copyWith(
      status: 'Pledged',
      pledgerId: widget.userId, // Add the pledgerId as the current user
    );

    try {
      // Update the gift in the owner's account
      await _giftDao.updateGift(pledgedGift, gift.userId);

      // Insert the pledged gift into the pledger's account
      await _giftDao.insertGift(
        pledgedGift.copyWith(userId: widget.userId), // Set userId as pledger's ID
      );

      print("Pledged gift saved: ${pledgedGift.toMap()}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift has been pledged!")),
      );

      _loadGifts(); // Reload gifts for the current view
    } catch (e) {
      print("Error pledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pledging gift.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFriendView ? "Friend's Gift List" : "Gift List for Event",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: sortCriteria,
            underline: SizedBox(),
            dropdownColor: Colors.blue[50],
            onChanged: (String? newCriteria) {
              setState(() {
                sortCriteria = newCriteria!;
                gifts = _sortGifts(gifts);
              });
            },
            items: ['Name', 'Category', 'Status'].map((criteria) {
              return DropdownMenuItem(
                value: criteria,
                child: Text(
                  criteria,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: gifts.isEmpty
          ? Center(
        child: Text(
          'No gifts available.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            color: _getGiftColor(gift.status),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      gift: gift,
                      userId: widget.userId,
                      isFriendView: widget.isFriendView,
                    ),
                  ),
                );
              },
              title: Text(
                gift.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                "Category: ${gift.category}\nStatus: ${gift.status}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black54),
              ),
              trailing: widget.isFriendView
                  ? null
                  : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _showAddOrEditGiftDialog(gift: gift);
                  } else if (value == 'Delete') {
                    setState(() {
                      gifts.remove(gift);
                    });
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: widget.isFriendView
          ? null
          : FloatingActionButton(
        onPressed: () => _showAddOrEditGiftDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add New Gift',
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}







