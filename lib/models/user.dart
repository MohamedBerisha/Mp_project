class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String? profileImage; // New field for profile image


  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    this.profileImage, // Optional field
  });

  // Convert a User into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'profileImage': profileImage, // Include profile image in the map
    };
  }

  // Extract a User from a Map. The keys must correspond to the names of the columns in the database.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      gender: map['gender'] as String,
      address: map['address'] as String,
      profileImage: map['profileImage'] as String?, // Extract profile image if available
    );
  }

  // Method to update user data fields
  User copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profileImage, // Allow updating profile image
  }) {
    return User(
      id: this.id, // ID remains unchanged
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage, // Update profile image if provided
    );
  }
}
