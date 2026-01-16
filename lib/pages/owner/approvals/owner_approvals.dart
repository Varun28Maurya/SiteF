import 'package:flutter/material.dart';

class OwnerApprovalsPage extends StatefulWidget {
  const OwnerApprovalsPage({super.key});

  @override
  State<OwnerApprovalsPage> createState() => _OwnerApprovalPage();
}


class _OwnerApprovalPage extends State<OwnerApprovalsPage> {
  String statusFilter = "all";

  List<Map<String, dynamic>> materialOrders = [
    {
      "id": "MO-001",
      "materialName": "Cement - OPC 53 Grade",
      "requestedQty": 500,
      "approvedQty": 450,
      "unit": "Bags",
      "siteLocation": "Tower A - Floor 5",
      "requestedBy": "Site Engineer - Rajesh",
      "status": "approved",
      "usedQty": 470,
      "remainingQty": -20,
      "leakage": true,
      "requestedAmount": 250000,
      "approvedAmount": 225000
    },
    {
      "id": "MO-002",
      "materialName": "TMT Steel Bars - 12mm",
      "requestedQty": 10,
      "approvedQty": 10,
      "unit": "Tons",
      "siteLocation": "Tower B - Floor 3",
      "requestedBy": "Site Engineer - Amit",
      "status": "approved",
      "usedQty": 8,
      "remainingQty": 2,
      "leakage": false,
      "requestedAmount": 500000,
      "approvedAmount": 500000
    },
    {
      "id": "MO-003",
      "materialName": "River Sand",
      "requestedQty": 15,
      "approvedQty": 0,
      "unit": "Tons",
      "siteLocation": "Tower A - Floor 2",
      "requestedBy": "Site Engineer - Priya",
      "status": "pending",
      "usedQty": 0,
      "remainingQty": 0,
      "leakage": false,
      "requestedAmount": 120000,
      "approvedAmount": 0
    },
  ];

  Map<String, dynamic>? selectedOrder;
  final qtyController = TextEditingController();
  final amountController = TextEditingController();
  bool showApprovalBox = false;

  List<Map<String, dynamic>> get filteredOrders {
    List<Map<String, dynamic>> list = materialOrders.where((o) {
      if (statusFilter == "all") return true;
      return o["status"] == statusFilter;
    }).toList();

    list.sort((a, b) {
      if (a["status"] == "pending" && b["status"] != "pending") return -1;
      if (a["status"] != "pending" && b["status"] == "pending") return 1;
      return 0;
    });
    return list;
  }

  void approveOrder(Map<String, dynamic> order) {
    setState(() {
      selectedOrder = order;
      qtyController.text = order["requestedQty"].toString();
      amountController.text = order["requestedAmount"].toString();
      showApprovalBox = true;
    });
  }

  void confirmApproval() {
    setState(() {
      for (var o in materialOrders) {
        if (o["id"] == selectedOrder!["id"]) {
          o["approvedQty"] = double.parse(qtyController.text);
          o["approvedAmount"] = double.parse(amountController.text);
          o["remainingQty"] = o["approvedQty"];
          o["status"] = "approved";
        }
      }
      showApprovalBox = false;
      selectedOrder = null;
    });
  }

  void rejectOrder(String id) {
    setState(() {
      for (var o in materialOrders) {
        if (o["id"] == id) o["status"] = "rejected";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Material Orders",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Manage material requisitions and approvals",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: ["all", "pending", "approved", "rejected"].map((s) {
                bool active = statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: active ? Colors.black : Colors.white,
                        foregroundColor: active ? Colors.white : Colors.grey,
                        side: const BorderSide(color: Colors.black12)),
                    onPressed: () => setState(() => statusFilter = s),
                    child: Text(s.toUpperCase()),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: filteredOrders.map((order) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: order["leakage"] ? Colors.red : Colors.transparent)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(order["materialName"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              if (order["leakage"])
                                const Chip(
                                    backgroundColor: Colors.redAccent,
                                    label: Text("Shortage",
                                        style: TextStyle(color: Colors.white)))
                            ],
                          ),
                          Text("Order ID: ${order["id"]}"),
                          Text("Location: ${order["siteLocation"]}"),
                          Text("Requested by: ${order["requestedBy"]}"),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Requested: ${order["requestedQty"]} ${order["unit"]}"),
                              Text("Approved: ${order["approvedQty"]}"),
                              Text("Used: ${order["usedQty"]}"),
                              Text(
                                "Remaining: ${order["remainingQty"]}",
                                style: TextStyle(
                                    color: order["remainingQty"] < 0
                                        ? Colors.red
                                        : Colors.black),
                              ),
                            ],
                          ),

                          const Divider(),

                          Text("Funds Requested: ₹${order["requestedAmount"]}"),
                          Text("Funds Approved: ₹${order["approvedAmount"]}"),

                          const SizedBox(height: 8),

                          if (order["status"] == "pending")
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: () => approveOrder(order),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    child: const Text("Approve")),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                    onPressed: () => rejectOrder(order["id"]),
                                    child: const Text("Reject"))
                              ],
                            ),

                          if (showApprovalBox && selectedOrder?["id"] == order["id"])
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(12),
                              color: Colors.orange[100],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Approve Quantity & Funds",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextField(
                                    controller: qtyController,
                                    decoration:
                                        const InputDecoration(labelText: "Approved Quantity"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextField(
                                    controller: amountController,
                                    decoration:
                                        const InputDecoration(labelText: "Approved Amount"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                          onPressed: confirmApproval,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: const Text("Confirm")),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                          onPressed: () =>
                                              setState(() => showApprovalBox = false),
                                          child: const Text("Cancel"))
                                    ],
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
