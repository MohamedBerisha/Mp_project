import 'package:flutter/material.dart';
import '../models/user.dart' as app_models; // Alias your app's User model
import '../data/local/user_dao.dart';

class UserInformationScreen extends StatefulWidget {
  final app_models.User user;

  UserInformationScreen({required this.user});

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserDao _userDao = UserDao();

  late app_models.User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      await _userDao.insertUser(_currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentUser.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _currentUser = _currentUser.copyWith(dateOfBirth: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Information"),
      centerTitle: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update Your Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _currentUser.name,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Name is required' : null,
                onChanged: (value) =>
                    setState(() => _currentUser = _currentUser.copyWith(name: value)),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _currentUser.email,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Email is required' : null,
                onChanged: (value) =>
                    setState(() => _currentUser = _currentUser.copyWith(email: value)),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _currentUser.phoneNumber ?? '',
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Phone number is required'
                    : null,
                onChanged: (value) =>
                    setState(() => _currentUser = _currentUser.copyWith(phoneNumber: value)),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _currentUser.address,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    setState(() => _currentUser = _currentUser.copyWith(address: value)),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  "Date of Birth: ${_currentUser.dateOfBirth != null ? _formatDate(_currentUser.dateOfBirth!) : 'Not Set'}",
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _selectDate,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserData,
                  child: Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
