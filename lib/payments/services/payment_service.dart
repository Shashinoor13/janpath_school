import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/payment.dart';
import 'package:janpath_school/models/student.dart';

class PaymentService {
  final DatabaseHelper _db = DatabaseHelper();

  /// Generate a unique bill number
  String generateBillNumber([String prefix = "PAY-"]) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomNum = (timestamp % 10000).toString().padLeft(4, '0');
    return "$prefix$dateStr-$randomNum";
  }

  /// Save payment with all related operations
  Future<Map<String, dynamic>> createPayment({
    required String? billNumber,
    required List<int>? billIds,
    required String? date,
    required String studentName,
    required String className,
    required String? rollNumber,
    required String? guardianName,
    required String? medium,
    required String? session,
    required String? parentName,
    required String? address,
    required double totalAmount,
    required String? totalInWords,
    required String? accountantSignature,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Ensure we have a bill number
      final finalBillNumber = billNumber?.isNotEmpty == true
          ? billNumber!
          : generateBillNumber("PAY-");

      // Validate required fields
      if (studentName.isEmpty) {
        return {'success': false, 'error': 'कृपया विद्यार्थीको नाम भर्नुहोस्।'};
      }

      if (className.isEmpty) {
        return {'success': false, 'error': 'कृपया कक्षा भर्नुहोस्।'};
      }

      if (totalAmount <= 0) {
        return {'success': false, 'error': 'कृपया भुक्तानी रकम भर्नुहोस्।'};
      }

      // Validate bills exist if billIds provided
      if (billIds != null && billIds.isNotEmpty) {
        for (final billId in billIds) {
          final bills = await _db.getStudentBills();
          final billExists = bills.any((bill) => bill.id == billId);
          if (!billExists) {
            return {'success': false, 'error': 'बिल नम्बर $billId फेला परेन।'};
          }
        }
      }

      // Prepare payment data
      final paymentData = {
        'billNumber': finalBillNumber,
        'billIds': billIds,
        'date': date,
        'studentName': studentName,
        'class': className,
        'rollNumber': rollNumber,
        'guardianName': guardianName,
        'paymentMode': medium,
        'session': session,
        'parentName': parentName,
        'address': address,
        'totalAmount': totalAmount,
        'totalInWords': totalInWords,
        'accountantSignature': accountantSignature,
        'items': items,
      };

      // Save payment
      final result = await _db.savePayment(paymentData);

      if (result['success'] == true) {
        // Create comprehensive response
        String message =
            'भुक्तानी सफलतापूर्वक बुझाइयो!\nबिल नं: $finalBillNumber';

        if (result['updatedBills']?.isNotEmpty == true) {
          final updatedBills =
              result['updatedBills'] as List<Map<String, dynamic>>;
          final totalDue = updatedBills.fold(
            0.0,
            (sum, bill) => sum + bill['remainingDue'],
          );

          message += '\n\nअपडेट भएका बिलहरू: ${updatedBills.length}';

          final fullyPaidBills = updatedBills
              .where((bill) => bill['remainingDue'] == 0)
              .length;
          final partiallyPaidBills = updatedBills
              .where((bill) => bill['remainingDue'] > 0)
              .length;

          if (fullyPaidBills > 0 && partiallyPaidBills == 0) {
            message =
                'भुक्तानी सफलतापूर्वक बुझाइयो! $fullyPaidBills बिलहरू पूरै भुक्तानी भयो।';
          } else if (partiallyPaidBills > 0) {
            message =
                'भुक्तानी सफलतापूर्वक बुझाइयो! ${updatedBills.length} बिलहरू अपडेट गरियो। बाँकी रकम: रु. ${totalDue.toStringAsFixed(2)}';
          }
        }

        return {
          'success': true,
          'payment': result['payment'],
          'updatedBills': result['updatedBills'],
          'message': message,
          'billNumber': finalBillNumber,
        };
      } else {
        return {'success': false, 'error': 'भुक्तानी सेभ गर्न सकिएन।'};
      }
    } catch (error) {
      return {
        'success': false,
        'error': 'भुक्तानी सिर्जना गर्दा त्रुटि भयो: ${error.toString()}',
      };
    }
  }

  /// Get payment history
  Future<List<Payment>> getPaymentHistory({int? limit}) async {
    return await _db.getPayments(limit: limit);
  }

  /// Get single payment with items
  Future<Payment?> getPaymentById(int id) async {
    final payment = await _db.getPayment(id);
    if (payment != null) {
      final items = await _db.getPaymentItems(id);
      return payment.copyWith(items: items);
    }
    return null;
  }

  /// Get unpaid bills for a student
  Future<List<UnpaidBillInfo>> getUnpaidBillsForStudent(int studentId) async {
    return await _db.getUnpaidBillsForStudent(studentId);
  }

  /// Search for students by name
  Future<List<Student?>?> searchStudents(String name) async {
    return await _db.getStudentByName(name);
  }

  /// Get student with class and section information
  Future<Map<String, dynamic>?> getStudentWithClassInfo(int studentId) async {
    final student = await _db.getStudent(studentId);
    if (student == null) return null;

    String className = '';
    String sectionName = '';

    if (student.classId != null) {
      final schoolClass = await _db.getClass(id: student.classId);
      className = schoolClass?.name ?? '';
    }

    if (student.sectionId != null) {
      final section = await _db.getSection(sectionId: student.sectionId);
      sectionName = section?.name ?? '';
    }

    final unpaidBills = await getUnpaidBillsForStudent(studentId);

    return {
      'student': student,
      'className': className,
      'sectionName': sectionName,
      'unpaidBills': unpaidBills,
    };
  }

  /// Validate payment data
  Map<String, dynamic> validatePaymentData({
    required String studentName,
    required String className,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) {
    List<String> errors = [];

    if (studentName.trim().isEmpty) {
      errors.add('कृपया विद्यार्थीको नाम भर्नुहोस्।');
    }

    if (className.trim().isEmpty) {
      errors.add('कृपया कक्षा भर्नुहोस्।');
    }

    if (totalAmount <= 0) {
      errors.add('कृपया भुक्तानी रकम भर्नुहोस्।');
    }

    if (items.isEmpty) {
      errors.add('कम्तिमा एक भुक्तानी विवरण आवश्यक छ।');
    }

    // Validate individual items
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item['amount'] == null || item['amount'] <= 0) {
        errors.add('वस्तु ${i + 1} को रकम मान्य छैन।');
      }
      if (item['description'] == null ||
          item['description'].toString().trim().isEmpty) {
        errors.add('वस्तु ${i + 1} को विवरण आवश्यक छ।');
      }
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? session,
  }) async {
    final payments = await _db.getPayments();

    // Filter by date range if provided
    List<Payment> filteredPayments = payments;
    if (startDate != null || endDate != null) {
      filteredPayments = payments.where((payment) {
        if (payment.date == null) return false;

        bool afterStart =
            startDate == null ||
            payment.date!.isAfter(startDate) ||
            payment.date!.isAtSameMomentAs(startDate);
        bool beforeEnd =
            endDate == null ||
            payment.date!.isBefore(endDate) ||
            payment.date!.isAtSameMomentAs(endDate);

        return afterStart && beforeEnd;
      }).toList();
    }

    // Filter by session if provided
    if (session != null) {
      filteredPayments = filteredPayments
          .where((payment) => payment.session == session)
          .toList();
    }

    final totalPayments = filteredPayments.length;
    final totalAmount = filteredPayments.fold(
      0.0,
      (sum, payment) => sum + (payment.totalAmount ?? 0),
    );
    final averagePayment = totalPayments > 0
        ? totalAmount / totalPayments
        : 0.0;

    // Group by month
    Map<String, double> monthlyData = {};
    for (final payment in filteredPayments) {
      if (payment.date != null) {
        final monthKey =
            '${payment.date!.year}-${payment.date!.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] =
            (monthlyData[monthKey] ?? 0) + (payment.totalAmount ?? 0);
      }
    }

    return {
      'totalPayments': totalPayments,
      'totalAmount': totalAmount,
      'averagePayment': averagePayment,
      'monthlyData': monthlyData,
    };
  }
}
