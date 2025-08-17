class Payment {
  final int? id;
  final String? billNumber;
  final DateTime? date;
  final String? studentName;
  final String? schoolClass;
  final String? rollNumber;
  final String? guardianName;
  final String? medium;
  final String? session;
  final String? parentName;
  final String? address;
  final double? totalAmount;
  final String? totalInWords;
  final String? accountantSignature;
  final DateTime createdAt;

  Payment({
    this.id,
    this.billNumber,
    this.date,
    this.studentName,
    this.schoolClass,
    this.rollNumber,
    this.guardianName,
    this.medium,
    this.session,
    this.parentName,
    this.address,
    this.totalAmount,
    this.totalInWords,
    this.accountantSignature,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNumber': billNumber,
      'date': date?.toIso8601String(),
      'studentName': studentName,
      'class': schoolClass,
      'rollNumber': rollNumber,
      'guardianName': guardianName,
      'medium': medium,
      'session': session,
      'parentName': parentName,
      'address': address,
      'totalAmount': totalAmount,
      'totalInWords': totalInWords,
      'accountantSignature': accountantSignature,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toInt(),
      billNumber: map['billNumber'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      studentName: map['studentName'],
      schoolClass: map['class'],
      rollNumber: map['rollNumber'],
      guardianName: map['guardianName'],
      medium: map['medium'],
      session: map['session'],
      parentName: map['parentName'],
      address: map['address'],
      totalAmount: map['totalAmount']?.toDouble(),
      totalInWords: map['totalInWords'],
      accountantSignature: map['accountantSignature'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
