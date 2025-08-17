class Section {
  final int? id;
  final String name;
  final int classId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Section({
    this.id,
    required this.name,
    required this.classId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classId': classId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      classId: map['classId']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
