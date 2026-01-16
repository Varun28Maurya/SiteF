import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  Map<String, dynamic> quotationData = {
    "projectName": "Residential Complex A",
    "clientName": "Abhilasa Tower",
    "items": [
      {
        "id": 1,
        "description": "PATCH WORK EXTERNAL CEMENT PLASTER",
        "fullDescription": "Cement plaster work with Dr. Fixit Pidiproof",
        "unit": "Sft",
        "area": 100.0,
        "rate": 90.0,
        "amount": 9000.0,
      }
    ],
    "gst": 18.0,
  };

  Map<String, dynamic>? generatedQuotation;

  double get subtotal =>
      quotationData["items"].fold(0.0, (s, i) => s + i["amount"]);

  double get total => subtotal + (subtotal * quotationData["gst"] / 100);

  void addItem() {
    setState(() {
      quotationData["items"].add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "description": "",
        "fullDescription": "",
        "unit": "Sft",
        "area": 0.0,
        "rate": 0.0,
        "amount": 0.0,
      });
    });
  }

  void updateItem(Map<String, dynamic> item, String key, dynamic value) {
    setState(() {
      item[key] = value;
      item["amount"] = (item["area"] ?? 0) * (item["rate"] ?? 0);
    });
  }

  void deleteItem(int id) {
    setState(() {
      quotationData["items"].removeWhere((e) => e["id"] == id);
    });
  }

  void generateQuotation() {
    setState(() {
      generatedQuotation = {
        ...quotationData,
        "subtotal": subtotal,
        "total": total,
        "quotationNumber":
            "QT-2024-${(100 + DateTime.now().millisecond % 900)}",
        "date": DateFormat.yMd("en_IN").format(DateTime.now())
      };
    });
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Center(
            child: pw.Text("QUOTATION",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Quotation No: ${generatedQuotation!["quotationNumber"]}"),
          pw.Text("Date: ${generatedQuotation!["date"]}"),
          pw.SizedBox(height: 15),
          pw.Text("Project: ${generatedQuotation!["projectName"]}"),
          pw.Text("Client: ${generatedQuotation!["clientName"]}"),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: [
              "S.No",
              "Description",
              "Unit",
              "Qty",
              "Rate",
              "Amount"
            ],
            data: List.generate(
              generatedQuotation!["items"].length,
              (i) {
                final item = generatedQuotation!["items"][i];
                return [
                  i + 1,
                  item["description"],
                  item["unit"],
                  item["area"],
                  "₹${item["rate"]}",
                  "₹${NumberFormat.decimalPattern('en_IN').format(item["amount"])}",
                ];
              },
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Subtotal: ₹${subtotal.toStringAsFixed(0)}"),
                pw.Text(
                    "GST (${quotationData["gst"]}%): ₹${(subtotal * quotationData["gst"] / 100).toStringAsFixed(0)}"),
                pw.Text("Total: ₹${total.toStringAsFixed(0)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
        leading: BackButton(),
        title: const Text("Quotation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              title: "Create Quotation",
              child: Column(
                children: [
                  _readonlyField("Project Name", quotationData["projectName"]),
                  _readonlyField("Client Name", quotationData["clientName"]),
                  const SizedBox(height: 20),

                  /// ITEMS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Items",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: addItem,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Item"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...quotationData["items"].map<Widget>((item) {
                    return _itemCard(item);
                  }).toList(),

                  const Divider(height: 32),

                  _totalRow("Subtotal", subtotal),
                  _totalRow(
                      "GST (${quotationData["gst"]}%)",
                      subtotal * quotationData["gst"] / 100),
                  _totalRow("Total", total, bold: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton(
                  onPressed: generateQuotation,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange),
                  child: const Text("Generate Quotation"),
                ),
                const SizedBox(width: 12),
                if (generatedQuotation != null)
                  OutlinedButton.icon(
                    onPressed: downloadPDF,
                    icon: const Icon(Icons.download),
                    label: const Text("Download PDF"),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// ---------------- UI HELPERS ----------------

  Widget _card({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child
        ]),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: value),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Item Description"),
              onChanged: (v) => updateItem(item, "description", v),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: "Full Description"),
              onChanged: (v) => updateItem(item, "fullDescription", v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _numberField("Unit", item["unit"],
                    (v) => updateItem(item, "unit", v)),
                _numberField("Qty", item["area"],
                    (v) => updateItem(item, "area", double.tryParse(v) ?? 0)),
                _numberField("Rate", item["rate"],
                    (v) => updateItem(item, "rate", double.tryParse(v) ?? 0)),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => deleteItem(item["id"]),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _numberField(
      String label, dynamic value, Function(String) onChange) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text("₹${NumberFormat.decimalPattern('en_IN').format(value)}",
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }
}