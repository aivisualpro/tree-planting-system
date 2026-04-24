import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CertificateGenerator {
  static Future<void> generateAndShareCertificate(String userName) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Certificate of Completion', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('This certifies that', style: const pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text(userName, style: pw.TextStyle(fontSize: 30, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 20),
                pw.Text('Has successfully completed the Field User Training Program for the Tree-Planting System.', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 40),
                pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Training_Certificate_${userName.replaceAll(' ', '_')}.pdf',
    );
  }
}
