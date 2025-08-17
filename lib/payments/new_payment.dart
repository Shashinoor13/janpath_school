import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart' hide UnpaidBillInfo;
import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/payments/models/payment_item.dart';
import 'package:janpath_school/payments/services/payment_pdf_services.dart';
import 'package:janpath_school/payments/services/payment_service.dart';
import 'package:janpath_school/payments/utils/payment_utils.dart';
import 'package:janpath_school/payments/widgets/payment_form_widget.dart';
import 'package:janpath_school/payments/widgets/student_search_field.dart';
import 'package:nepali_utils/nepali_utils.dart';

class NewPaymentScreen extends StatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  State<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  // Services
  final PaymentService _paymentService = PaymentService();

  // Student and bill data
  Student? _selectedStudent;
  String _className = '';
  String _sectionName = '';
  List<UnpaidBillInfo> _unpaidBills = [];
  List<UnpaidBillInfo> _selectedBills = [];
  int tableRebuildKey = 0;

  // Form controllers
  final TextEditingController _billNumberController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _sessionController = TextEditingController();
  final TextEditingController _paymentModeController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _accountantSignatureController =
      TextEditingController();

  // Payment data
  List<PaymentItem> _paymentItems = [];
  double _totalAmount = 0.0;
  String _totalInWords = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentItems();
    _setDefaultValues();
    _calculateTotal();
  }

  void _initializePaymentItems() {
    _paymentItems = PaymentItem.getDefaultItems();
  }

  void _setDefaultValues() {
    // Set default date to today's Nepali date
    final nepaliDate = NepaliDateTime.now();
    _dateController.text = NepaliDateFormat("yyyy-MM-dd").format(nepaliDate);
    // Set default payment mode
    _paymentModeController.text = 'नगद'; // Cash in Nepali
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = _paymentItems.fold(0.0, (sum, item) => sum + item.amount);
      _totalInWords = PaymentUtils.convertNumberToNepaliWords(_totalAmount);
    });
  }

  void _onBillSelected(UnpaidBillInfo bill, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedBills.any((b) => b.bill.id == bill.bill.id)) {
          _selectedBills.add(bill);
        }
      } else {
        _selectedBills.removeWhere((b) => b.bill.id == bill.bill.id);
      }
      _generateBillNumber();
    });
  }

  void _onStudentSelected(
    Student student,
    String className,
    String sectionName,
    List<UnpaidBillInfo> unpaidBills,
  ) async {
    setState(() {
      _selectedStudent = student;
      _className = className;
      _sectionName = sectionName;
      _unpaidBills = unpaidBills;
      _selectedBills = [];
    });

    // Auto-fill form fields
    _studentNameController.text = student.name ?? '';
    _classController.text = className;
    if (sectionName.isNotEmpty) {
      _classController.text = "$className-$sectionName";
    }
    _rollNumberController.text = student.rollNumber?.toString() ?? '';
    _guardianNameController.text = student.parentName ?? '';
    _parentNameController.text = student.parentName ?? '';
    _addressController.text = student.address ?? '';
    _sessionController.text = student.session ?? '';

    _billNumberController.clear();
  }

  void _generateBillNumber() {
    if (_selectedBills.isNotEmpty) {
      _billNumberController.text = PaymentUtils.generateBillNumberFromBills(
        _selectedBills,
      );
    }
  }

  void _autoPopulateFromBills() {
    if (_selectedBills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया पहिले बिल छान्नुहोस्।'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double totalFromBills = 0;

    for (var billInfo in _selectedBills) {
      if (billInfo.unpaidAmount > 0) {
        // Add to "कक्षागत प्रयोगात्मक वापत" or "अन्य..." item
        int targetIndex = _paymentItems.indexWhere(
          (item) => item.description == "कक्षागत प्रयोगात्मक वापत",
        );

        if (targetIndex == -1) {
          targetIndex = _paymentItems.indexWhere(
            (item) => item.description == "अन्य...",
          );
        }

        if (targetIndex != -1) {
          setState(() {
            _paymentItems[targetIndex].amount += billInfo.unpaidAmount;
            final sessionInfo = "${billInfo.bill.session} शुल्क";
            if (_paymentItems[targetIndex].remarks.isEmpty) {
              _paymentItems[targetIndex].remarks = sessionInfo;
            } else {
              _paymentItems[targetIndex].remarks += ", $sessionInfo";
            }
            tableRebuildKey++;
          });
        }
        totalFromBills += billInfo.unpaidAmount;
      }
    }

    if (totalFromBills > 0) {
      _calculateTotal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'चयनित बिलहरूबाट रु. ${totalFromBills.toStringAsFixed(2)} स्वचालित रूपमा भरिएको छ।',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('चयनित सबै बिलहरू भुक्तानी भइसकेको छ।'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onPaymentItemAmountChanged(PaymentItem item, double amount) {
    setState(() {
      item.amount = amount;
      _calculateTotal();
      tableRebuildKey++;
    });
  }

  void _onPaymentItemRemarksChanged(PaymentItem item, String remarks) {
    setState(() {
      item.remarks = remarks;
      tableRebuildKey++;
    });
  }

  Widget _buildPaymentForm() {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'नयाँ भुक्तानी फारम',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Student Search
            PaymentFormWidgets.buildFormSection(
              'विद्यार्थी खोज्नुहोस्',
              child: StudentSearchField(
                onSelected: (student, name, classSection, bills) {
                  _onStudentSelected(
                    student,
                    name,
                    classSection,
                    bills
                        .map(
                          (bill) => UnpaidBillInfo(
                            bill: bill.bill,
                            unpaidAmount: bill.unpaidAmount,
                            classFee: bill.classFee,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),

            // Unpaid Bills Selection
            if (_unpaidBills.isNotEmpty)
              PaymentFormWidgets.buildFormSection(
                'बकाया बिलहरू',
                child: PaymentFormWidgets.buildBillsSelection(
                  _unpaidBills.cast<UnpaidBillInfo>(),
                  _selectedBills.cast<UnpaidBillInfo>(),
                  (UnpaidBillInfo bill, bool isSelected) =>
                      _onBillSelected(bill, isSelected),
                  _autoPopulateFromBills,
                ),
              ),

            // Basic Info Row
            PaymentFormWidgets.buildFormSection(
              'आधारभूत जानकारी',
              child: Row(
                children: [
                  Expanded(
                    child: PaymentFormWidgets.buildTextField(
                      'बिल नं.',
                      _billNumberController,
                      hint: 'स्वचालित',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PaymentFormWidgets.buildDateField(
                      _dateController,
                      context,
                    ),
                  ),
                ],
              ),
            ),

            // Student Details Grid
            PaymentFormWidgets.buildFormSection(
              'विद्यार्थी विवरण',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'नाम',
                          _studentNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'कक्षा',
                          _classController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'रोल नं.',
                          _rollNumberController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'सत्र',
                          _sessionController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'अभिभावक',
                          _guardianNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentFormWidgets.buildPaymentModeDropdown(
                          _paymentModeController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'शिक्षा प्रेमी श्री',
                          _parentNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentFormWidgets.buildTextField(
                          'ठेगाना',
                          _addressController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Items
            PaymentFormWidgets.buildFormSection(
              'भुक्तानी विवरण',
              child: PaymentFormWidgets.buildPaymentItemsTable(
                key: ValueKey(tableRebuildKey),
                _paymentItems,
                _onPaymentItemAmountChanged,
                _onPaymentItemRemarksChanged,
              ),
            ),

            // Total and Submit
            PaymentFormWidgets.buildTotalSection(_totalAmount, _totalInWords),
            const SizedBox(height: 16),
            PaymentFormWidgets.buildTextField(
              'लेखापालको हस्ताक्षर',
              _accountantSignatureController,
            ),
            const SizedBox(height: 20),

            // Action buttons with loading state
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PaymentFormWidgets.buildActionButtons(
                    _savePayment,
                    _clearForm,
                  ),
          ],
        ),
      ),
    );
  }

  void _savePayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Basic validation
      if (_selectedStudent == null) {
        _showError('कृपया पहिले विद्यार्थी छान्नुहोस्');
        return;
      }

      // Prepare payment items
      final items = _paymentItems
          .where((item) => item.amount > 0)
          .map(
            (item) => {
              'description': item.description,
              'amount': item.amount,
              'remarks': item.remarks,
            },
          )
          .toList();

      // Create payment using the service
      final result = await _paymentService.createPayment(
        billNumber: _billNumberController.text,
        billIds: _selectedBills.map((b) => b.bill.id!).toList(),
        date: _dateController.text,
        studentName: _studentNameController.text,
        className: _classController.text,
        rollNumber: _rollNumberController.text,
        guardianName: _guardianNameController.text,
        medium: _paymentModeController.text,
        session: _sessionController.text,
        parentName: _parentNameController.text,
        address: _addressController.text,
        totalAmount: _totalAmount,
        totalInWords: _totalInWords,
        accountantSignature: _accountantSignatureController.text,
        items: items,
      );

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'भुक्तानी सफलतापूर्वक बुझाइयो!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Prepare payment data for PDF
        final paymentData = {
          'billNumber': result['billNumber'],
          'date': _dateController.text,
          'studentName': _studentNameController.text,
          'class': _classController.text,
          'rollNumber': _rollNumberController.text,
          'guardianName': _guardianNameController.text,
          'session': _sessionController.text,
          'parentName': _parentNameController.text,
          'address': _addressController.text,
          'totalAmount': _totalAmount,
          'totalInWords': _totalInWords,
          'accountantSignature': _accountantSignatureController.text,
          'items': items,
        };

        // Print functionality
        await PaymentPdfService.printPayment(context, paymentData);

        // Clear form after successful submission
        _clearForm();
      } else {
        _showError(result['error'] ?? 'भुक्तानी सेभ गर्न सकिएन।');
      }
    } catch (e) {
      _showError('त्रुटि: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedStudent = null;
      _className = '';
      _sectionName = '';
      _unpaidBills = [];
      _selectedBills = [];

      // Reset payment items
      _initializePaymentItems();
      _totalAmount = 0.0;
      _totalInWords = '';
    });

    // Clear all controllers except date and payment mode
    _billNumberController.clear();
    _studentNameController.clear();
    _classController.clear();
    _rollNumberController.clear();
    _guardianNameController.clear();
    _sessionController.clear();
    _parentNameController.clear();
    _addressController.clear();
    _accountantSignatureController.clear();

    // Reset defaults
    _setDefaultValues();
    _calculateTotal();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _billNumberController.dispose();
    _dateController.dispose();
    _studentNameController.dispose();
    _classController.dispose();
    _rollNumberController.dispose();
    _guardianNameController.dispose();
    _sessionController.dispose();
    _paymentModeController.dispose();
    _parentNameController.dispose();
    _addressController.dispose();
    _accountantSignatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'New Payment',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Payment form
              _buildPaymentForm(),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/payments'),
                child: const Text('Back to Payments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
