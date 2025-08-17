import 'package:uuid/uuid.dart';

class StudentBill {
  final int? id;
  final String? billNumber;
  final int studentId;
  final int classFeeId;
  final DateTime billedAt;
  final double amountPaid;
  final String session;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentBill({
    this.id,
    String? billNumber,
    required this.studentId,
    required this.classFeeId,
    DateTime? billedAt,
    required this.amountPaid,
    required this.session,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : billNumber = billNumber ?? const Uuid().v4(),
       billedAt = billedAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNumber': billNumber,
      'studentId': studentId,
      'classFeeId': classFeeId,
      'billedAt': billedAt.toIso8601String(),
      'amountPaid': amountPaid,
      'session': session,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudentBill.fromMap(Map<String, dynamic> map) {
    return StudentBill(
      id: map['id']?.toInt(),
      billNumber: map['billNumber'],
      studentId: map['studentId']?.toInt() ?? 0,
      classFeeId: map['classFeeId']?.toInt() ?? 0,
      billedAt: DateTime.parse(map['billedAt']),
      amountPaid: map['amountPaid']?.toDouble() ?? 0.0,
      session: map['session'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
