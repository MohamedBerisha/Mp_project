class Friend {
  final String id;
  final String name;
  final String profileImage;
   int upcomingEvents;
  final String phoneNumber;
  final String userId; // New field to associate the friend with a user

  Friend({
    required this.id,
    required this.name,
    required this.profileImage,
    this.upcomingEvents = 0, // Default value is 0
    required this.phoneNumber,
    required this.userId,
  });

  /// Converts Friend object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'upcomingEvents': upcomingEvents,
      'phoneNumber': phoneNumber,
      'userId': userId, // Include userId in the map
    };
  }

  /// Creates a Friend object from a Map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      profileImage: map['profileImage'],
      upcomingEvents: map['upcomingEvents'] ?? 0,
      phoneNumber: map['phoneNumber'],
      userId: map['userId'], // Parse userId from the map
    );
  }

  /// Creates a modified copy of the Friend object
  Friend copyWith({
    String? id,
    String? name,
    String? profileImage,
    int? upcomingEvents,
    String? phoneNumber,
    String? userId,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userId: userId ?? this.userId, // Allow updating userId
    );
  }
}
