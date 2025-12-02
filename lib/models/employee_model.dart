class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final DateTime joinedDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.joinedDate,
  });

  // Convert Employee to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  // Create Employee from Firestore document
  factory Employee.fromMap(Map<String, dynamic> map, String id) {
    return Employee(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'] ?? '',
      joinedDate: map['joinedDate'] != null
          ? DateTime.parse(map['joinedDate'])
          : DateTime.now(),
    );
  }

  // Create a copy of Employee with updated fields
  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    DateTime? joinedDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

