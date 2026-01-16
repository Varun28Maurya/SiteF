import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GstInvoicePage extends StatefulWidget {
  const GstInvoicePage({super.key});

  @override
  State<GstInvoicePage> createState() => _GstInvoicePageState();
}

class _GstInvoicePageState extends State<GstInvoicePage> {
  Map<String, dynamic> gstInvoiceData = {
    "companyName": "ConstructPro Private Limited",
    "companyGSTIN": "29ABCDE1234F1Z5",
    "companyAddress": "123, MG Road, Bengaluru, Karnataka - 560001",
    "clientName": "",
    "clientGSTIN": "",
    "clientAddress": "",
    "invoiceNumber": "GST-2024-${100 + DateTime.now().millisecond % 900}",
    "invoiceDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    "hsnCode": "9954",
    "placeOfSupply": "Karnataka",
  };

  bool showGSTInvoice = false;
  bool invoiceGenerated = false;

  final items = [
    {
      "description": "PATCH WORK EXTERNAL CEMENT PLASTER",
      "unit": "Sft",
      "area": 100,
      "rate": 90,
      "amount": 9000,
    }
  ];

  double get subtotal =>
      items.fold(0.0, (sum, i) => sum + (i["amount"] as num).toDouble());

  double get gstAmount => gstInvoiceData["placeOfSupply"] == "Karnataka"
      ? subtotal * 0.18
      : subtotal * 0.18;

  double get total => subtotal + gstAmount;

  void generateInvoice() {
    if (gstInvoiceData["clientName"].isEmpty ||
        gstInvoiceData["clientGSTIN"].isEmpty ||
        gstInvoiceData["clientAddress"].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required client details")),
      );
      return;
    }
    setState(() {
      showGSTInvoice = true;
      invoiceGenerated = true;
    });
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Center(
            child: pw.Text(
              "TAX INVOICE",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          /// COMPANY
          pw.Text(gstInvoiceData["companyName"],
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text("GSTIN: ${gstInvoiceData["companyGSTIN"]}"),
          pw.Text(gstInvoiceData["companyAddress"]),
          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Invoice No: ${gstInvoiceData["invoiceNumber"]}"),
              pw.Text("Date: ${gstInvoiceData["invoiceDate"]}"),
            ],
          ),

          pw.SizedBox(height: 20),

          /// CLIENT
          pw.Text("Bill To:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(gstInvoiceData["clientName"]),
          pw.Text("GSTIN: ${gstInvoiceData["clientGSTIN"]}"),
          pw.Text(gstInvoiceData["clientAddress"]),

          pw.SizedBox(height: 20),

          /// TABLE
          pw.Table.fromTextArray(
            headers: [
              "S.No",
              "Description",
              "HSN",
              "Unit",
              "Qty",
              "Rate",
              "Amount"
            ],
            data: List.generate(items.length, (i) {
              final item = items[i];
              return [
                i + 1,
                item["description"],
                gstInvoiceData["hsnCode"],
                item["unit"],
                item["area"],
                "₹${item["rate"]}",
                "₹${NumberFormat.decimalPattern('en_IN').format(item["amount"])}",
              ];
            }),
          ),

          pw.SizedBox(height: 20),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                    "Subtotal: ₹${NumberFormat.decimalPattern('en_IN').format(subtotal)}"),
                if (gstInvoiceData["placeOfSupply"] == "Karnataka") ...[
                  pw.Text(
                      "CGST (9%): ₹${NumberFormat.decimalPattern('en_IN').format(subtotal * 0.09)}"),
                  pw.Text(
                      "SGST (9%): ₹${NumberFormat.decimalPattern('en_IN').format(subtotal * 0.09)}"),
                ] else
                  pw.Text(
                      "IGST (18%): ₹${NumberFormat.decimalPattern('en_IN').format(subtotal * 0.18)}"),
                pw.Text(
                  "Total: ₹${NumberFormat.decimalPattern('en_IN').format(total)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("GST Invoice"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              title: "Create GST Invoice",
              child: Column(
                children: [
                  _readonly("Invoice Number", gstInvoiceData["invoiceNumber"]),
                  _readonly("Invoice Date", gstInvoiceData["invoiceDate"]),
                  const Divider(),

                  /// COMPANY
                  _infoBlock("Company Details", [
                    gstInvoiceData["companyName"],
                    gstInvoiceData["companyGSTIN"],
                    gstInvoiceData["companyAddress"],
                  ]),

                  /// CLIENT
                  _input(
                      "Client Name *", (v) => gstInvoiceData["clientName"] = v),
                  _input("Client GSTIN *",
                      (v) => gstInvoiceData["clientGSTIN"] = v),
                  _input("Client Address *",
                      (v) => gstInvoiceData["clientAddress"] = v),

                  DropdownButtonFormField<String>(
                    value: gstInvoiceData["placeOfSupply"],
                    decoration:
                        const InputDecoration(labelText: "Place of Supply"),
                    items: const [
                      DropdownMenuItem(
                          value: "Karnataka",
                          child: Text("Karnataka (CGST + SGST)")),
                      DropdownMenuItem(
                          value: "Other", child: Text("Other State (IGST)")),
                    ],
                    onChanged: (v) =>
                        setState(() => gstInvoiceData["placeOfSupply"] = v),
                  ),

                  const Divider(height: 30),

                  /// ITEMS
                  ...items.map((item) => ListTile(
                        title: Text("${item["description"] ?? ""}"),
                        subtitle: Text(
                          "HSN ${gstInvoiceData["hsnCode"]} | ${item["area"] ?? 0} ${item["unit"] ?? ""} × ₹${item["rate"] ?? 0}",
                        ),
                        trailing: Text(
                          "₹${NumberFormat.decimalPattern('en_IN').format((item["amount"] as num).toDouble())}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),

                  const Divider(),

                  _totalRow("Subtotal", subtotal),
                  if (gstInvoiceData["placeOfSupply"] == "Karnataka") ...[
                    _totalRow("CGST (9%)", subtotal * 0.09),
                    _totalRow("SGST (9%)", subtotal * 0.09),
                  ] else
                    _totalRow("IGST (18%)", subtotal * 0.18),
                  _totalRow("Total", total, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: generateInvoice,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Generate GST Invoice"),
                ),
                const SizedBox(width: 12),
                if (invoiceGenerated)
                  OutlinedButton.icon(
                    onPressed: downloadPDF,
                    icon: const Icon(Icons.download),
                    label: const Text("Download PDF"),
                  ),
              ],
            ),
            if (showGSTInvoice)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.green.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text("GST Invoice Generated Successfully!"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget _card({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child
        ]),
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: value),
    );
  }

  Widget _input(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _infoBlock(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...lines.map((l) => Text(l)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(
          "₹${NumberFormat.decimalPattern('en_IN').format(value)}",
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    );
  }
}
