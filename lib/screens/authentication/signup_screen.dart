import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/friend.dart';
import '../../models/user.dart' as app_models;
import '../../data/local/user_dao.dart';
import 'login_screen.dart';
import '../../data/local/friend_dao.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'Choose Gender';
  final List<String> _genders = ['Male', 'Female'];
  bool _dateOfBirthError = false;

  /// Submit Form Logic
  void _submitForm() async {
    setState(() {
      _dateOfBirthError = _dateOfBirth == null;
    });

    if (_formKey.currentState!.validate() && !_dateOfBirthError) {
      try {
        // Firebase signup
        auth.UserCredential userCredential = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userId = userCredential.user!.uid;

        // Determine profile image based on gender
        String profileImage = _gender == 'Male'
            ? 'assets/male.webp'
            : _gender == 'Female'
            ? 'assets/female.webp'
            : '';

        // Create a new user object
        final newUser = app_models.User(
          id: userId,
          name: '${_nameController.text.trim()} ${_lastNameController.text.trim()}',
          email: _emailController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          dateOfBirth: _dateOfBirth!,
          gender: _gender,
          address: _addressController.text.trim(),
          profileImage: profileImage,
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set(newUser.toMap());

        // Save user data locally
        final userDao = UserDao();
        await userDao.insertUser(newUser);

        // Navigate to LoginScreen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    }
  }

  /// Select Date of Birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2024),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Title
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Join us today and manage your gifts effortlessly!',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
                SizedBox(height: 20),

                // First Name
                _buildTextField(_nameController, 'First Name'),
                SizedBox(height: 15),

                // Last Name
                _buildTextField(_lastNameController, 'Last Name'),
                SizedBox(height: 15),

                // Email
                _buildTextField(_emailController, 'Email'),
                SizedBox(height: 15),

                // Password
                _buildPasswordField(_passwordController, 'Password'),
                SizedBox(height: 15),

                // Confirm Password
                _buildPasswordField(_confirmPasswordController, 'Confirm Password'),
                SizedBox(height: 15),

                // Phone Number
                _buildTextField(_phoneNumberController, 'Phone Number'),
                SizedBox(height: 15),

                // Address
                _buildTextField(_addressController, 'Address'),
                SizedBox(height: 15),

                // Date of Birth
                ListTile(
                  tileColor: Colors.white,
                  title: Text(
                    'Date of Birth: ${_dateOfBirth != null ? _dateOfBirth!.toLocal().toString().split(' ')[0] : 'Select Date'}',
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
                  onTap: () => _selectDate(context),
                ),
                if (_dateOfBirthError)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Date of Birth is required', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                SizedBox(height: 15),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender == 'Choose Gender' ? null : _gender,
                  decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  onChanged: (String? newValue) {
                    setState(() => _gender = newValue ?? 'Choose Gender');
                  },
                  items: _genders.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Please select a gender' : null,
                ),
                SizedBox(height: 20),

                // Signup Button
                ElevatedButton(
                  key: Key('signupSubmitButton'),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),


// Link to Login Page
                SizedBox(height: 15),
                GestureDetector(
                  key: Key('loginLink'),  // Add a Key to the login link
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: Text(
                    'Already have an account? Log In',
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent, decoration: TextDecoration.underline),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label is required';
        if (label == 'Confirm Password' && value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}
