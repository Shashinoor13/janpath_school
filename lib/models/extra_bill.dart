import 'package:uuid/uuid.dart';

class ExtraBill {
  final int? id;
  final String? billNumber;
  final int studentId;
  final String description;
  final double amount;
  final DateTime billedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExtraBill({
    this.id,
    String? billNumber,
    required this.studentId,
    required this.description,
    required this.amount,
    DateTime? billedAt,
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
      'description': description,
      'amount': amount,
      'billedAt': billedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExtraBill.fromMap(Map<String, dynamic> map) {
    return ExtraBill(
      id: map['id']?.toInt(),
      billNumber: map['billNumber'],
      studentId: map['studentId']?.toInt() ?? 0,
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      billedAt: DateTime.parse(map['billedAt']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
