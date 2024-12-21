class Events {
  final String id;
  final String name;
  final String category;
  final String status;
  final String userId;
  final String? description; // New field
  final String? location; // New field
  final String? date; // New field
  final String? imageUrl; // New field

  Events({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.userId,
    this.description,
    this.location,
    this.date,
    this.imageUrl,
  });

  // Convert an Events object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'userId': userId,
      'description': description,
      'location': location,
      'date': date,
      'imageUrl': imageUrl,
    };
  }

  // Create an Events object from a map
  factory Events.fromMap(Map<String, dynamic> map) {
    return Events(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      status: map['status'],
      userId: map['userId'],
      description: map['description'],
      location: map['location'],
      date: map['date'],
      imageUrl: map['imageUrl'],
    );
  }
}
