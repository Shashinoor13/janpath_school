import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';

import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/payments/widgets/student_search_field.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
}

class NewPaymentScreen extends StatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  State<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  Student? _selectedStudent;
  String _className = '';
  String _sectionName = '';
  List<UnpaidBillInfo> _unpaidBills = [];
  List<UnpaidBillInfo> _selectedBills = [];

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

  // Payment items list
  List<PaymentItem> _paymentItems = [];
  double _totalAmount = 0.0;
  String _totalInWords = '';

  final DatabaseHelper _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializePaymentItems();
    // Set default date to today's Nepali date
    final nepaliDate = NepaliDateTime.now();
    _dateController.text = NepaliDateFormat("yyyy-MM-dd").format(nepaliDate);
    // Set default payment mode
    _paymentModeController.text = 'नगद'; // Cash in Nepali
    _calculateTotal();
  }

  void _initializePaymentItems() {
    _paymentItems = [
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

  void _calculateTotal() {
    setState(() {
      _totalAmount = _paymentItems.fold(0.0, (sum, item) => sum + item.amount);
      _totalInWords = _convertNumberToNepaliWords(_totalAmount);
    });
  }

  String _convertNumberToNepaliWords(double num) {
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
      return "${_convertHundreds(intNum)} रुपैयाँ मात्र";
    } else if (intNum < 100000) {
      final thousands = intNum ~/ 1000;
      final remainder = intNum % 1000;
      String result = "${_convertHundreds(thousands)} हजार";
      if (remainder > 0) {
        result += " ${_convertHundreds(remainder)}";
      }
      return "$result रुपैयाँ मात्र";
    } else {
      return "${intNum.toString()} रुपैयाँ मात्र";
    }
  }

  String _convertHundreds(int n) {
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
      if (_selectedBills.length == 1) {
        _billNumberController.text = _selectedBills.first.bill.id.toString();
      } else {
        final now = DateTime.now();
        final dateStr =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
        final randomNum =
            (1000 + (DateTime.now().millisecondsSinceEpoch % 9000));
        _billNumberController.text = "$dateStr-$randomNum";
      }
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
            _buildFormSection(
              'विद्यार्थी खोज्नुहोस्',
              child: StudentSearchField(onSelected: _onStudentSelected),
            ),

            // Unpaid Bills Selection
            if (_unpaidBills.isNotEmpty)
              _buildFormSection('बकाया बिलहरू', child: _buildBillsSelection()),

            // Basic Info Row
            _buildFormSection(
              'आधारभूत जानकारी',
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'बिल नं.',
                      _billNumberController,
                      hint: 'स्वचालित',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField()),
                ],
              ),
            ),

            // Student Details Grid
            _buildFormSection(
              'विद्यार्थी विवरण',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('नाम', _studentNameController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('कक्षा', _classController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'रोल नं.',
                          _rollNumberController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('सत्र', _sessionController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'अभिभावक',
                          _guardianNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPaymentModeDropdown()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'शिक्षा प्रेमी श्री',
                          _parentNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('ठेगाना', _addressController),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Items
            _buildFormSection(
              'भुक्तानी विवरण',
              child: _buildPaymentItemsTable(),
            ),

            // Total and Submit
            _buildTotalSection(),
            const SizedBox(height: 16),
            _buildTextField(
              'लेखापालको हस्ताक्षर',
              _accountantSignatureController,
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'मिति',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 16),
            isDense: true,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              _dateController.text = date.toString().split(' ')[0];
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'माध्यम',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _paymentModeController.text.isEmpty
              ? null
              : _paymentModeController.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'नगद', child: Text('नगद')),
            DropdownMenuItem(value: 'चेक', child: Text('चेक')),
            DropdownMenuItem(value: 'अनलाइन', child: Text('अनलाइन')),
          ],
          onChanged: (value) {
            _paymentModeController.text = value ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildBillsSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _unpaidBills.map((bill) {
              final isSelected = _selectedBills.any(
                (b) => b.bill.id == bill.bill.id,
              );
              return InkWell(
                onTap: () => _onBillSelected(bill, !isSelected),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) =>
                            _onBillSelected(bill, value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'सत्र: ${bill.bill.session}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'बाँकी: रु. ${bill.unpaidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedBills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _autoPopulateFromBills,
                  icon: const Icon(Icons.auto_fix_high, size: 14),
                  label: const Text(
                    'भर्नुहोस्',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                Text(
                  'जम्मा: रु. ${_selectedBills.fold(0.0, (sum, bill) => sum + bill.unpaidAmount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    'सि.नं.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'विवरण',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'रकम',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'कैफियत',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentItems.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              final item = _paymentItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        item.sn.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 11),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          setState(() {
                            item.amount = double.tryParse(value) ?? 0.0;
                            _calculateTotal();
                          });
                        },
                        controller: TextEditingController(
                          text: item.amount == 0 ? '' : item.amount.toString(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          hintText: 'कैफियत',
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 11),
                        onChanged: (value) {
                          setState(() {
                            item.remarks = value;
                          });
                        },
                        controller: TextEditingController(text: item.remarks),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'जम्मा:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                'रु. ${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'अदद अक्षरेपी:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(_totalInWords, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _savePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('फारम बुझाउनुहोस्'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _clearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('रिसेट गर्नुहोस्'),
          ),
        ),
      ],
    );
  }

  void _savePayment() {
    // Validation
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया पहिले विद्यार्थी छान्नुहोस्'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_studentNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया विद्यार्थीको नाम भर्नुहोस्।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया कक्षा भर्नुहोस्।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया भुक्तानी रकम भर्नुहोस्।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create payment data
    final paymentData = {
      'billNumber': _billNumberController.text.isNotEmpty
          ? _billNumberController.text
          : _generateAutoBillNumber(),
      'billIds': _selectedBills.map((b) => b.bill.id).toList(),
      'date': _dateController.text,
      'studentName': _studentNameController.text,
      'class': _classController.text,
      'rollNumber': _rollNumberController.text,
      'guardianName': _guardianNameController.text,
      'session': _sessionController.text,
      'parentName': _parentNameController.text,
      'address': _addressController.text,
      'paymentMode': _paymentModeController.text,
      'items': _paymentItems
          .where((item) => item.amount > 0)
          .map(
            (item) => {
              'description': item.description,
              'amount': item.amount,
              'remarks': item.remarks,
            },
          )
          .toList(),
      'totalAmount': _totalAmount,
      'totalInWords': _totalInWords,
      'accountantSignature': _accountantSignatureController.text,
    };

    // TODO: Save to database using your existing methods
    // Example: _db.savePayment(paymentData);

    // Show success message with detailed information
    String successMessage =
        'भुक्तानी सफलतापूर्वक बुझाइयो!\nबिल नं: ${paymentData['billNumber']}';

    if (_selectedBills.isNotEmpty) {
      successMessage += '\n\nअपडेट भएका बिलहरू: ${_selectedBills.length}';
      for (int i = 0; i < _selectedBills.length; i++) {
        final bill = _selectedBills[i];
        successMessage +=
            '\nबिल ${i + 1}: रु. ${bill.unpaidAmount.toStringAsFixed(2)} भुक्तानी गरियो';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );

    // Print functionality (you can implement this based on your printing requirements)
    _printPayment(context, paymentData);

    // Clear form after successful submission
    _clearForm();
  }

  String _generateAutoBillNumber() {
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomNum = (1000 + (now.millisecondsSinceEpoch % 9000));
    return "$dateStr-$randomNum";
  }

  void _printPayment(
    BuildContext context,
    Map<String, dynamic> paymentData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "श्री जनतपथ विद्यालय",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text("भुक्तानी विवरण - ${paymentData['billNumber']}"),
              pw.Text("मिति: ${paymentData['date']}"),
              pw.SizedBox(height: 12),

              pw.Text("विद्यार्थी: ${paymentData['studentName']}"),
              pw.Text("कक्षा: ${paymentData['class']}"),
              pw.Text("रोल नम्बर: ${paymentData['rollNumber']}"),
              pw.Text("अभिभावक: ${paymentData['guardianName']}"),
              pw.Text("सत्र: ${paymentData['session']}"),
              pw.Text("ठेगाना: ${paymentData['address']}"),
              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("क्र.स."),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("विवरण"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("रकम (रु.)"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("कैफियत"),
                      ),
                    ],
                  ),
                  ...List.generate(paymentData['items'].length, (index) {
                    final item = paymentData['items'][index];
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("${index + 1}"),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item['description']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item['amount'].toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item['remarks'] ?? ""),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text("जम्मा: रु. ${paymentData['totalAmount']}"),
              pw.Text("शब्दमा जम्मा: ${paymentData['totalInWords']}"),
              pw.SizedBox(height: 20),
              pw.Text(
                "लेखापालको हस्ताक्षर: ${paymentData['accountantSignature'] ?? ''}",
              ),
            ],
          );
        },
      ),
    );

    // Open print preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
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
    final nepaliDate = NepaliDateTime.now();
    _dateController.text = NepaliDateFormat("yyyy-MM-dd").format(nepaliDate);
    _paymentModeController.text = 'नगद';

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
              // Payment form (always shows)
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
