class PaymentItem {
  final int? id;
  final int paymentId;
  final int sn;
  final String description;
  final double amount;
  final String? remarks;

  PaymentItem({
    this.id,
    required this.paymentId,
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

  factory PaymentItem.fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      id: map['id']?.toInt(),
      paymentId: map['paymentId']?.toInt() ?? 0,
      sn: map['sn']?.toInt() ?? 0,
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      remarks: map['remarks'],
    );
  }
}
