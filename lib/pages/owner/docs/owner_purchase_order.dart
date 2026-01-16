
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  Map<String, dynamic> poData = {
    "vendor": "",
    "poNumber": "PO-2024-${100 + DateTime.now().millisecond % 900}",
    "issueDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    "deliveryDate": "",
    "approvedBy": "",
    "status": "pending",
    "items": [
      {
        "id": 1,
        "description": "PATCH WORK EXTERNAL CEMENT PLASTER",
        "unit": "Sft",
        "area": 100,
        "rate": 90,
        "amount": 9000,
      }
    ],
    "totalAmount": 10620,
  };

  bool poApproved = false;
  bool showSuccess = false;

  final List<Map<String, dynamic>> purchaseOrders = [
    {
      "id": "PO-2024-045",
      "vendor": "ABC Suppliers",
      "project": "Commercial Tower B",
      "amount": 725000,
      "status": "Pending",
      "date": "2024-01-14",
    },
    {
      "id": "PO-2024-046",
      "vendor": "XYZ Materials",
      "project": "Residential Complex A",
      "amount": 550000,
      "status": "Approved",
      "date": "2024-01-12",
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  void approvePO() {
    if (poData["vendor"].isEmpty ||
        poData["deliveryDate"].isEmpty ||
        poData["approvedBy"].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      poApproved = true;
      showSuccess = true;
      poData["status"] = "approved";
    });
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Center(
            child: pw.Text(
              "PURCHASE ORDER",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text("PO Number: ${poData["poNumber"]}"),
          pw.Text("Issue Date: ${poData["issueDate"]}"),
          pw.Text("Delivery Date: ${poData["deliveryDate"]}"),
          pw.SizedBox(height: 15),
          pw.Text("Vendor: ${poData["vendor"]}"),
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
            data: List.generate(poData["items"].length, (i) {
              final item = poData["items"][i];
              return [
                i + 1,
                item["description"],
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
            child: pw.Text(
              "Total Amount: ₹${NumberFormat.decimalPattern('en_IN').format(poData["totalAmount"])}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Approved By: ${poData["approvedBy"]}"),
          pw.Text("Status: ${poData["status"].toUpperCase()}"),
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
        title: const Text("Purchase Orders"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Create PO"),
            Tab(text: "PO History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _createPOTab(),
          _historyTab(),
        ],
      ),
    );
  }

  /// ---------------- CREATE PO TAB ----------------

  Widget _createPOTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            title: "Create Purchase Order",
            child: Column(
              children: [
                _field("PO Number", poData["poNumber"], readOnly: true),
                _field("Vendor Name *", poData["vendor"],
                    onChanged: (v) => poData["vendor"] = v),
                _field("Issue Date", poData["issueDate"], readOnly: true),
                _field("Delivery Date *", poData["deliveryDate"],
                    onChanged: (v) => poData["deliveryDate"] = v),
                _field("Approved By *", poData["approvedBy"],
                    onChanged: (v) => poData["approvedBy"] = v),
                const Divider(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Items",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ...poData["items"].map<Widget>((item) {
                  return ListTile(
                    title: Text(item["description"]),
                    subtitle: Text(
                        "${item["area"]} ${item["unit"]} × ₹${item["rate"]}"),
                    trailing: Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(item["amount"])}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Total Amount: ₹${NumberFormat.decimalPattern('en_IN').format(poData["totalAmount"])}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: approvePO,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange),
                child: const Text("Generate Purchase Order"),
              ),
              const SizedBox(width: 12),
              if (poApproved)
                OutlinedButton.icon(
                  onPressed: downloadPDF,
                  icon: const Icon(Icons.download),
                  label: const Text("Download PDF"),
                )
            ],
          ),
          if (showSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading:
                      const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text(
                      "Purchase Order Generated Successfully!"),
                  subtitle: Text("PO Number: ${poData["poNumber"]}"),
                ),
              ),
            )
        ],
      ),
    );
  }

  /// ---------------- HISTORY TAB ----------------

  Widget _historyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchaseOrders.length,
      itemBuilder: (_, i) {
        final po = purchaseOrders[i];
        return Card(
          child: ListTile(
            title: Text(po["id"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(po["vendor"]),
                Text(po["project"],
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${NumberFormat.decimalPattern('en_IN').format(po["amount"])}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(po["date"], style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(po["status"]),
                  backgroundColor: po["status"] == "Approved"
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// ---------------- HELPERS ----------------

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

  Widget _field(String label, String value,
      {bool readOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        readOnly: readOnly,
        decoration: InputDecoration(labelText: label),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }
}