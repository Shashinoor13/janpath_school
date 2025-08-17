// Models
class Student {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final int? classId;
  final int? sectionId;
  final String? rollNumber;
  final String? guardianName;
  final String? medium;
  final String? session;
  final String? parentName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.classId,
    this.sectionId,
    this.rollNumber,
    this.guardianName,
    this.medium,
    this.session,
    this.parentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'classId': classId,
      'sectionId': sectionId,
      'rollNumber': rollNumber,
      'guardianName': guardianName,
      'medium': medium,
      'session': session,
      'parentName': parentName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      classId: map['classId']?.toInt(),
      sectionId: map['sectionId']?.toInt(),
      rollNumber: map['rollNumber'],
      guardianName: map['guardianName'],
      medium: map['medium'],
      session: map['session'],
      parentName: map['parentName'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
