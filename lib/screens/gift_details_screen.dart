import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gift.dart';
import '../data/local/gift_dao.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final String userId; // Added userId for DAO operations
  final bool isFriendView;

  GiftDetailsPage({
    required this.gift,
    required this.userId,
    this.isFriendView = false,
  });

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final GiftDao _giftDao = GiftDao();

  late String _name;
  late String _description;
  late String _category;
  late double _price;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _loadGift();
  }

  /// Loads gift details and updates local variables
  void _loadGift() {
    setState(() {
      _name = widget.gift.name;
      _description = widget.gift.description ?? '';
      _category = widget.gift.category;
      _price = widget.gift.price ?? 0.0;
      _imagePath = widget.gift.imagePath ?? '';
    });
  }

  void _saveGiftDetails() async {
    if (_formKey.currentState!.validate()) {
      final imagePath = _getImageForCategory(_category.trim().toLowerCase());

      final updatedGift = widget.gift.copyWith(
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        imagePath: imagePath,
        status: 'Available',
      );

      await _giftDao.updateGift(updatedGift, widget.userId);
      Navigator.pop(context, updatedGift);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift details updated successfully.")),
      );
    }
  }

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




  /// Allows picking an image for the gift
  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  /// Handles pledging a friend's gift
  void _pledgeGift() async {
    if (widget.gift.status != 'Available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("This gift is already pledged or purchased.")),
      );
      return;
    }

    final pledgedGift = widget.gift.copyWith(
      status: 'Pledged',
      pledgerId: widget.userId, // Add the pledger's userId
    );

    try {
      // Update the gift in the friend's account
      await _giftDao.updateGift(pledgedGift, widget.gift.userId);

      // Insert the pledged gift into the pledger's account
      await _giftDao.insertGift(
        pledgedGift.copyWith(userId: widget.userId), // Save under the pledger's userId
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift has been pledged!")),
      );

      Navigator.pop(context, pledgedGift); // Return with updated gift
    } catch (e) {
      print("Error pledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pledging gift.")),
      );
    }
  }

  /// Builds a read-only field for friend's gift details
  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }

  /// Builds an editable field for user's gift details
  Widget _buildEditableField(
      String label,
      String initialValue,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isFriendView ? "Friend's Gift Details" : "Gift Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.isFriendView
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadOnlyField('Gift Name', widget.gift.name),
            SizedBox(height: 16),
            _buildReadOnlyField('Category', widget.gift.category),
            SizedBox(height: 16),
            _buildReadOnlyField(
                'Description', widget.gift.description ?? 'No description provided'),
            SizedBox(height: 16),
            _buildReadOnlyField(
              'Price',
              widget.gift.price != null
                  ? "\$${widget.gift.price!.toStringAsFixed(2)}"
                  : "N/A",
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _pledgeGift,
                child: Text(
                  "Pledge Gift",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        )
            : Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEditableField('Gift Name', _name, (value) => _name = value),
              SizedBox(height: 16),
              _buildEditableField('Description', _description, (value) => _description = value),
              SizedBox(height: 16),
              _buildEditableField('Category', _category, (value) => _category = value),
              SizedBox(height: 16),
              _buildEditableField(
                'Price',
                _price.toStringAsFixed(2),
                    (value) => _price = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _imagePath.isEmpty
                  ? TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload, color: Colors.blue),
                label: Text('Upload Image',
                    style: TextStyle(color: Colors.blue, fontSize: 16)),
              )
                  : Image.file(
                File(_imagePath),
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGiftDetails,
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
