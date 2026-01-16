import 'package:flutter/material.dart';

/// ============================================================
/// MODEL
/// ============================================================
enum RequestType { material, funds }

class RequestItem {
  final String id;
  final String projectName;
  final RequestType type;

  final String title; // Cement / Funds for Slab etc.
  final String subtitle; // Qty/Unit OR amount text
  final String requestedBy;

  String status; // pending, approved, rejected

  final DateTime createdAt;

  RequestItem({
    required this.id,
    required this.projectName,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
  });
}

/// ============================================================
/// PAGE
/// ============================================================
class EngineerMaterialsFundsPage extends StatefulWidget {
  final String role; // ENGINEER / MANAGER
  const EngineerMaterialsFundsPage({super.key, this.role = "Enigineer"});

  @override
  State<EngineerMaterialsFundsPage> createState() => _EngineerMaterialsFundsPageState();
}

class _EngineerMaterialsFundsPageState extends State<EngineerMaterialsFundsPage> {
  String statusFilter = "all";
  String searchQuery = "";

  /// ✅ seed demo data (later replace with API)
  final List<RequestItem> allRequests = [
    RequestItem(
      id: "REQ-001",
      projectName: "Skyline Residency",
      type: RequestType.material,
      title: "Cement (OPC 53 Grade)",
      subtitle: "500 Bags",
      requestedBy: "Engineer - Rajesh",
      status: "pending",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RequestItem(
      id: "REQ-002",
      projectName: "Skyline Residency",
      type: RequestType.funds,
      title: "Funds Request",
      subtitle: "₹2,50,000",
      requestedBy: "Engineer - Priya",
      status: "approved",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RequestItem(
      id: "REQ-003",
      projectName: "Green Towers",
      type: RequestType.material,
      title: "TMT Steel 12mm",
      subtitle: "10 Tons",
      requestedBy: "Manager - Suresh",
      status: "rejected",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<RequestItem> get filteredList {
    var list = allRequests.toList();

    // ✅ filter by status
    if (statusFilter != "all") {
      list = list.where((r) => r.status == statusFilter).toList();
    }

    // ✅ global search
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.projectName.toLowerCase().contains(q) ||
            r.requestedBy.toLowerCase().contains(q) ||
            r.id.toLowerCase().contains(q);
      }).toList();
    }

    // ✅ pending first
    list.sort((a, b) {
      if (a.status == "pending" && b.status != "pending") return -1;
      if (a.status != "pending" && b.status == "pending") return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  /// ============================================================
  /// CREATE REQUEST MODAL
  /// ============================================================
  void _openCreateModal(RequestType type) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              Text(
                type == RequestType.material ? "New Material Request" : "New Funds Request",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: type == RequestType.material ? "Material name (e.g. Cement)" : "Purpose (e.g. Funds for slab)",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: subtitleCtrl,
                keyboardType: type == RequestType.funds ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(
                  hintText: type == RequestType.material ? "Quantity + Unit (e.g. 500 Bags)" : "Amount (e.g. 250000)",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3C5D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final sub = subtitleCtrl.text.trim();
                    if (title.isEmpty || sub.isEmpty) return;

                    setState(() {
                      allRequests.insert(
                        0,
                        RequestItem(
                          id: "REQ-${DateTime.now().millisecondsSinceEpoch}",
                          projectName: "All Projects", // later select project dropdown
                          type: type,
                          title: title,
                          subtitle: type == RequestType.funds ? "₹$sub" : sub,
                          requestedBy: "${widget.role} - You",
                          status: "pending",
                          createdAt: DateTime.now(),
                        ),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Create Request", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _typeIcon(RequestType type) {
    return type == RequestType.material ? Icons.inventory_2 : Icons.payments;
  }

  String _typeLabel(RequestType type) {
    return type == RequestType.material ? "MATERIAL" : "FUNDS";
  }

  /// ============================================================
  /// UI
  /// ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ✅ Top Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Request",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage all material & funds requests across projects",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                // ✅ 2 buttons row
                Row(
                  children: [
                    Expanded(
                      child: _PrimaryActionButton(
                        text: "+ Material",
                        icon: Icons.add_box_rounded,
                        onTap: () => _openCreateModal(RequestType.material),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrimaryActionButton(
                        text: "+ Funds",
                        icon: Icons.add_card_rounded,
                        onTap: () => _openCreateModal(RequestType.funds),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ✅ Search
                TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search requests (material, project, ID...)",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Filters
                Row(
                  children: ["all", "pending", "approved", "rejected"].map((s) {
                    final active = statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => statusFilter = s),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            s.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: active ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ✅ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final r = filteredList[index];

                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_typeIcon(r.type), color: Colors.orange),
                      ),
                      const SizedBox(width: 12),

                      // content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // top row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(r.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    r.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: _statusColor(r.status),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(
                              "${r.projectName} • ${_typeLabel(r.type)}",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              r.subtitle,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              "Requested By: ${r.requestedBy} • ${r.id}",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500),
                            ),

                            const SizedBox(height: 10),

                            // action row
                            if (r.status == "pending")
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      onPressed: () => setState(() => r.status = "approved"),
                                      child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      onPressed: () => setState(() => r.status = "rejected"),
                                      child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

/// ============================================================
/// Button component
/// ============================================================
class _PrimaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B3C5D),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 10),
              color: Color(0x240B3C5D),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
