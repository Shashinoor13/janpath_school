class PaymentItem {
  final int sn;
  final String description;
  double amount;
  String remarks;

  PaymentItem({
    required this.sn,
    required this.description,
    this.amount = 0.0,
    this.remarks = '',
  });

  static List<PaymentItem> getDefaultItems() {
    return [
      PaymentItem(sn: 1, description: "अभिभावक सहयोग"),
      PaymentItem(sn: 2, description: "एस.ई.ई. परीक्षा राजस्व"),
      PaymentItem(sn: 3, description: "कक्षागत प्रयोगात्मक वापत"),
      PaymentItem(
        sn: 4,
        description: "परीक्षा शुल्क (प्रथम/दोस्रो/तेस्रो/वार्षिक)",
      ),
      PaymentItem(sn: 5, description: "प्रमाण-पत्र (एस.ई.ई./एल.सी)"),
      PaymentItem(sn: 6, description: "मूल प्रमाण-पत्र"),
      PaymentItem(sn: 7, description: "विद्यालय विकास सहयोग वापत"),
      PaymentItem(sn: 8, description: "कक्षा-११/१२ शिक्षण वापत"),
      PaymentItem(sn: 9, description: "कक्षा-११/१२ भर्ना वापत"),
      PaymentItem(sn: 10, description: "रजिष्ट्रेशन वापत/कक्षा ९/११"),
      PaymentItem(sn: 11, description: "परीक्षा फारम/प्रवेश परीक्षा वापत"),
      PaymentItem(sn: 12, description: "सिफारिस वापत"),
      PaymentItem(sn: 13, description: "विगत बाँकी"),
      PaymentItem(sn: 14, description: "परिचय पत्र वापत"),
      PaymentItem(sn: 15, description: "अन्य..."),
    ];
  }
}
