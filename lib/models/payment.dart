class Payment {
  final int? id;
  final String? billNumber;
  final DateTime? date;
  final String? studentName;
  final String? classValue;
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
  final List<PaymentItem>? items;

  Payment({
    this.id,
    this.billNumber,
    this.date,
    this.studentName,
    this.classValue,
    this.rollNumber,
    this.guardianName,
    this.medium,
    this.session,
    this.parentName,
    this.address,
    this.totalAmount,
    this.totalInWords,
    this.accountantSignature,
    required this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNumber': billNumber,
      'date': date?.toIso8601String(),
      'studentName': studentName,
      'class': classValue,
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

  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      billNumber: map['billNumber'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      studentName: map['studentName'],
      classValue: map['class'],
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

  Payment copyWith({
    int? id,
    String? billNumber,
    DateTime? date,
    String? studentName,
    String? classValue,
    String? rollNumber,
    String? guardianName,
    String? medium,
    String? session,
    String? parentName,
    String? address,
    double? totalAmount,
    String? totalInWords,
    String? accountantSignature,
    DateTime? createdAt,
    List<PaymentItem>? items,
  }) {
    return Payment(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      date: date ?? this.date,
      studentName: studentName ?? this.studentName,
      classValue: classValue ?? this.classValue,
      rollNumber: rollNumber ?? this.rollNumber,
      guardianName: guardianName ?? this.guardianName,
      medium: medium ?? this.medium,
      session: session ?? this.session,
      parentName: parentName ?? this.parentName,
      address: address ?? this.address,
      totalAmount: totalAmount ?? this.totalAmount,
      totalInWords: totalInWords ?? this.totalInWords,
      accountantSignature: accountantSignature ?? this.accountantSignature,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

class PaymentItem {
  final int? id;
  final int? paymentId;
  final int sn;
  final String description;
  final double amount;
  final String? remarks;

  PaymentItem({
    this.id,
    this.paymentId,
    required this.sn,
    required this.description,
    required this.amount,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentId': paymentId,
      'sn': sn,
      'description': description,
      'amount': amount,
      'remarks': remarks,
    };
  }

  static PaymentItem fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      id: map['id'],
      paymentId: map['paymentId'],
      sn: map['sn'],
      description: map['description'],
      amount: map['amount']?.toDouble() ?? 0.0,
      remarks: map['remarks'],
    );
  }
}
