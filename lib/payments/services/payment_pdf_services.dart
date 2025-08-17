import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentPdfService {
  static Future<void> printPayment(
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
              // Header
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

              // Bill Info
              pw.Text("भुक्तानी विवरण - ${paymentData['billNumber']}"),
              pw.Text("मिति: ${paymentData['date']}"),
              pw.SizedBox(height: 12),

              // Student Details
              pw.Text("विद्यार्थी: ${paymentData['studentName']}"),
              pw.Text("कक्षा: ${paymentData['class']}"),
              pw.Text("रोल नम्बर: ${paymentData['rollNumber']}"),
              pw.Text("अभिभावक: ${paymentData['guardianName']}"),
              pw.Text("सत्र: ${paymentData['session']}"),
              pw.Text("ठेगाना: ${paymentData['address']}"),
              pw.SizedBox(height: 12),

              // Payment Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header Row
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
                  // Data Rows
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

              // Total Section
              pw.Text("जम्मा: रु. ${paymentData['totalAmount']}"),
              pw.Text("शब्दमा जम्मा: ${paymentData['totalInWords']}"),
              pw.SizedBox(height: 20),

              // Signature
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
}
