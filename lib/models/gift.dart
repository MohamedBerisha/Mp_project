import 'dart:convert'; // Ensure this import is added

class Gift {
  final String id;
  String name;
  final String category;
  final String status;
  String? description;
  double? price;
  String? imagePath;
  final String eventID;
  String? friendName;
  DateTime? dueDate;
  bool? isPending;
  final String userId; // New field to associate the gift with a user
  final String? pledgerId; // ID of the user who pledged the gift

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.description,
    this.price,
    this.imagePath,
    required this.eventID,
    this.friendName,
    this.dueDate,
    this.isPending,
    required this.userId, // Ensure userId is required
    this.pledgerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'eventID': eventID,
      'friendName': friendName,
      'dueDate': dueDate?.toIso8601String(),
      'isPending': isPending == null ? null : (isPending! ? 1 : 0),
      'userId': userId, // Include userId in the map
      'pledgerId': pledgerId, // Add pledgerId
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      status: map['status'],
      description: map['description'],
      price: (map['price'] as num?)?.toDouble(), // Ensure price is parsed as double
      imagePath: map['imagePath'],
      eventID: map['eventID'],
      friendName: map['friendName'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isPending: map['isPending'] == null ? null : (map['isPending'] == 1),
      userId: map['userId'], // Parse userId from the map
      pledgerId: map['pledgerId'], // Parse pledgerId
    );
  }

  String toJson() => json.encode(toMap());

  factory Gift.fromJson(String source) => Gift.fromMap(json.decode(source));

  Gift copyWith({
    String? id,
    String? name,
    String? category,
    String? status,
    String? description,
    double? price,
    String? imagePath,
    String? eventID,
    String? friendName,
    DateTime? dueDate,
    bool? isPending,
    String? userId,
    String? pledgerId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      eventID: eventID ?? this.eventID,
      friendName: friendName ?? this.friendName,
      dueDate: dueDate ?? this.dueDate,
      isPending: isPending ?? this.isPending,
      userId: userId ?? this.userId, // Ensure userId can be updated
      pledgerId: pledgerId ?? this.pledgerId,
    );
  }
}
