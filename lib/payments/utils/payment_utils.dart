import 'dart:math';

class PaymentUtils {
  static String convertNumberToNepaliWords(double num) {
    if (num == 0) return "सुन्ना रुपैयाँ मात्र";

    final ones = [
      "",
      "एक",
      "दुई",
      "तीन",
      "चार",
      "पाँच",
      "छ",
      "सात",
      "आठ",
      "नौ",
    ];
    final teens = [
      "दश",
      "एघार",
      "बाह्र",
      "तेह्र",
      "चौध",
      "पन्ध्र",
      "सोह्र",
      "सत्र",
      "अठार",
      "उन्नाइस",
    ];
    final tens = [
      "",
      "",
      "बीस",
      "तीस",
      "चालीस",
      "पचास",
      "साठी",
      "सत्तरी",
      "असी",
      "नब्बे",
    ];

    int intNum = num.round();

    if (intNum < 1000) {
      return "${_convertHundreds(intNum, ones, teens, tens)} रुपैयाँ मात्र";
    } else if (intNum < 100000) {
      final thousands = intNum ~/ 1000;
      final remainder = intNum % 1000;
      String result = "${_convertHundreds(thousands, ones, teens, tens)} हजार";
      if (remainder > 0) {
        result += " ${_convertHundreds(remainder, ones, teens, tens)}";
      }
      return "$result रुपैयाँ मात्र";
    } else {
      return "${intNum.toString()} रुपैयाँ मात्र";
    }
  }

  static String _convertHundreds(
    int n,
    List<String> ones,
    List<String> teens,
    List<String> tens,
  ) {
    String result = "";

    if (n >= 100) {
      result += "${ones[n ~/ 100]} सय ";
      n %= 100;
    }

    if (n >= 20) {
      result += tens[n ~/ 10];
      if (n % 10 != 0) {
        result += " ${ones[n % 10]}";
      }
    } else if (n >= 10) {
      result += teens[n - 10];
    } else if (n > 0) {
      result += ones[n];
    }

    return result.trim();
  }

  static String generateAutoBillNumber() {
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomNum = (1000 + (now.millisecondsSinceEpoch % 9000));
    return "$dateStr-$randomNum";
  }

  static String generateBillNumberFromBills(List<dynamic> selectedBills) {
    if (selectedBills.isEmpty) return '';

    if (selectedBills.length == 1) {
      return selectedBills.first.bill.id.toString();
    } else {
      return generateAutoBillNumber();
    }
  }
}
