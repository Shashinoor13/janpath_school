import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/payment.dart';
import 'package:flutter/services.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> payments = [];
  List<Payment> filteredPayments = [];
  String selectedPeriod = 'आज';
  DateTime? customStartDate;
  DateTime? customEndDate;
  String searchQuery = '';
  bool isLoading = true;

  // Analytics data
  double totalToday = 0;
  double totalWeek = 0;
  double totalMonth = 0;
  int totalTransactions = 0;
  Map<String, int> dailyTransactions = {};

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => isLoading = true);
    try {
      final fetchedPayments = await DatabaseHelper().getPayments();
      setState(() {
        payments = fetchedPayments;
        _calculateAnalytics();
        _filterPayments();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('डेटा लोड गर्न समस्या भयो: $e');
    }
  }

  void _calculateAnalytics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    totalToday = 0;
    totalWeek = 0;
    totalMonth = 0;
    totalTransactions = payments.length;
    dailyTransactions.clear();

    for (var payment in payments) {
      final paymentDate = DateTime.tryParse(
        payment.createdAt.toString().toString() ?? '',
      );
      if (paymentDate != null) {
        final amount = payment.totalAmount ?? 0;

        // Daily totals
        if (paymentDate.isAfter(today.subtract(const Duration(days: 1)))) {
          totalToday += amount;
        }
        if (paymentDate.isAfter(weekAgo)) {
          totalWeek += amount;
        }
        if (paymentDate.isAfter(monthAgo)) {
          totalMonth += amount;
        }

        // Daily transactions count
        final dateKey = '${paymentDate.day}/${paymentDate.month}';
        dailyTransactions[dateKey] = (dailyTransactions[dateKey] ?? 0) + 1;
      }
    }
  }

  void _filterPayments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<Payment> filtered = payments;

    // Filter by period
    switch (selectedPeriod) {
      case 'आज':
        filtered = payments.where((p) {
          final date = DateTime.tryParse(p.createdAt.toString() ?? '');
          return date != null &&
              date.isAfter(today.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'यो हप्ता':
        final weekAgo = today.subtract(const Duration(days: 7));
        filtered = payments.where((p) {
          final date = DateTime.tryParse(p.createdAt.toString() ?? '');
          return date != null && date.isAfter(weekAgo);
        }).toList();
        break;
      case '३० दिन':
        final monthAgo = today.subtract(const Duration(days: 30));
        filtered = payments.where((p) {
          final date = DateTime.tryParse(p.createdAt.toString() ?? '');
          return date != null && date.isAfter(monthAgo);
        }).toList();
        break;
      case 'कस्टम':
        if (customStartDate != null && customEndDate != null) {
          filtered = payments.where((p) {
            final date = DateTime.tryParse(p.createdAt.toString() ?? '');
            return date != null &&
                date.isAfter(
                  customStartDate!.subtract(const Duration(days: 1)),
                ) &&
                date.isBefore(customEndDate!.add(const Duration(days: 1)));
          }).toList();
        }
        break;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return (p.studentName?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ??
                false) ||
            (p.id?.toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ??
                false);
      }).toList();
    }

    setState(() {
      filteredPayments = filtered;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _printPayments() {
    // Implement print functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('प्रिन्ट सुविधा जल्द आउनेछ...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
        selectedPeriod = 'कस्टम';
      });
      _filterPayments();
    }
  }

  Widget _buildCompactAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'भुक्तानी व्यवस्थापन',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalyticsCards(),
                  const SizedBox(height: 16),
                  _buildFiltersAndActions(),
                  const SizedBox(height: 16),
                  _buildPaymentsTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactAnalyticsCard(
              'आजको भुक्तानी',
              'रु. ${totalToday.toStringAsFixed(2)}',
              Icons.today,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildCompactAnalyticsCard(
              'यो हप्ता',
              'रु. ${totalWeek.toStringAsFixed(2)}',
              Icons.calendar_view_week,
              Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildCompactAnalyticsCard(
              '३० दिन',
              'रु. ${totalMonth.toStringAsFixed(2)}',
              Icons.calendar_month,
              Colors.orange,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildCompactAnalyticsCard(
              'कुल लेनदेन',
              totalTransactions.toString(),
              Icons.receipt_long,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.grey.shade400, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'विद्यार्थी नाम वा रसिद नम्बर खोज्नुहोस्...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _filterPayments();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _printPayments,
                icon: const Icon(Icons.print, size: 18),
                label: const Text('प्रिन्ट'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildPeriodChip('आज'),
              _buildPeriodChip('यो हप्ता'),
              _buildPeriodChip('३० दिन'),
              _buildCustomPeriodChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = selectedPeriod == period;
    return FilterChip(
      label: Text(period),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedPeriod = period;
        });
        _filterPayments();
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomPeriodChip() {
    final isSelected = selectedPeriod == 'कस्टम';
    return FilterChip(
      label: Text(
        isSelected && customStartDate != null
            ? 'कस्टम (${customStartDate!.day}/${customStartDate!.month} - ${customEndDate!.day}/${customEndDate!.month})'
            : 'कस्टम मिति',
      ),
      selected: isSelected,
      onSelected: (selected) => _selectCustomDateRange(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPaymentsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'भुक्तानी सूची',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'कुल: ${filteredPayments.length} रेकर्ड',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (filteredPayments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'कुनै भुक्तानी रेकर्ड फेला परेन',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                horizontalMargin: 16,
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(
                    label: Text(
                      'रसिद नम्बर',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'विद्यार्थी नाम',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'कक्षा',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'रकम',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'मिति',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'कार्य',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                rows: filteredPayments.map((payment) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          payment.id.toString() ?? '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          payment.studentName ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          payment.classValue ?? '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          'रु. ${payment.totalAmount?.toStringAsFixed(2) ?? '0'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          payment.createdAt.toString() ?? '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 16),
                              onPressed: () => _viewPaymentDetails(payment),
                              tooltip: 'विवरण हेर्नुहोस्',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.print, size: 16),
                              onPressed: () => _printSinglePayment(payment),
                              tooltip: 'प्रिन्ट गर्नुहोस्',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _viewPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('भुक्तानी विवरण - ${payment.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('विद्यार्थी नाम:', payment.studentName ?? '-'),
              _buildDetailRow('कक्षा:', payment.classValue ?? '-'),
              _buildDetailRow(
                'कुल रकम:',
                'रु. ${payment.totalAmount?.toStringAsFixed(2) ?? '0'}',
              ),
              _buildDetailRow('मिति:', payment.createdAt.toString() ?? '-'),
              if (payment.totalInWords?.isNotEmpty == true)
                _buildDetailRow('अक्षरमा:', payment.totalInWords!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बन्द गर्नुहोस्'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _printSinglePayment(Payment payment) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${payment.id} को प्रिन्ट सुविधा जल्द आउनेछ...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
