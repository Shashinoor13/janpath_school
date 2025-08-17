class ClassFee {
  final int? id;
  final int? classId;
  final int? sectionId;
  final double classFee;
  final String session;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassFee({
    this.id,
    this.classId,
    this.sectionId,
    required this.classFee,
    required this.session,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'sectionId': sectionId,
      'classFee': classFee,
      'session': session,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ClassFee.fromMap(Map<String, dynamic> map) {
    return ClassFee(
      id: map['id']?.toInt(),
      classId: map['classId']?.toInt(),
      sectionId: map['sectionId']?.toInt(),
      classFee: map['classFee']?.toDouble() ?? 0.0,
      session: map['session'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
  @override
  String toString() {
    return 'ClassFee(id: $id, classId: $classId, sectionId: $sectionId, classFee: $classFee, session: $session, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
