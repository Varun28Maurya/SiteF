import 'dart:async';
import 'package:flutter/material.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  bool isLoading = true;
  static const String OWNER_ID = "owner-1";

  List<Map<String, dynamic>> projects = [];
  final Map<String, dynamic> store = {};

  @override
  void initState() {
    super.initState();
    _seedData();

    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        projects = List<Map<String, dynamic>>.from(store["projects"]);
        isLoading = false;
      });
    });
  }

  void _seedData() {
    store["projects"] ??= [
      {
        "id": "proj-1",
        "name": "Skyline Residency",
        "ownerId": "owner-1",
        "engineerId": "eng-1",
        "location": "Worli, Mumbai",
        "progress": 75,
        "startDate": "Jan 2024",
      },
      {
        "id": "proj-2",
        "name": "Green Valley Villas",
        "ownerId": "owner-1",
        "engineerId": "eng-1",
        "location": "Sector 45, Gurgaon",
        "progress": 42,
        "startDate": "Mar 2024",
      }
    ];

    store["dpr-proj-1"] = true;
    store["dpr-proj-2"] = false;

    store["materials-proj-2"] = [
      {"item": "Cement", "status": "Pending"},
      {"item": "Steel", "status": "Pending"},
    ];
  }

  List<Map<String, dynamic>> get projectStatus {
    return projects.where((p) => p["ownerId"] == OWNER_ID).map((p) {
      final bool dpr = store["dpr-${p["id"]}"] == true;
      final List mats = store["materials-${p["id"]}"] ?? [];
      final pending = mats.where((m) => m["status"] == "Pending").length;

      return {
        ...p,
        "dprSubmitted": dpr,
        "pendingMaterials": pending,
        "attention": (!dpr || pending > 0),
      };
    }).toList();
  }

  Map<String, int> get stats {
    return {
      "active": projectStatus.length,
      "onTrack": projectStatus.where((p) => p["attention"] == false).length,
      "needAttention": projectStatus.where((p) => p["attention"] == true).length,
      "pendingRequests": projectStatus.fold(
        0,
        (sum, p) => sum + (p["pendingMaterials"] as int),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B3C5D)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ TOP HEADER (React-like)
            const Text(
              "Owner Dashboard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor all projects, DPRs and requests in one place.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 14),

            // ✅ ALERT BANNER
            _AlertBanner(
              title: "${stats["needAttention"]} Projects need attention",
              subtitle: "DPR pending or material/funds approvals required",
            ),

            const SizedBox(height: 14),

            // ✅ KPI CARDS (compact)
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.85,
              children: [
                _KpiCard(
                  title: "Active Projects",
                  value: stats["active"]!,
                  icon: Icons.apartment_rounded,
                  bg: const Color(0xFFEFF6FF),
                  fg: const Color(0xFF2563EB),
                ),
                _KpiCard(
                  title: "On Track",
                  value: stats["onTrack"]!,
                  icon: Icons.check_circle_rounded,
                  bg: const Color(0xFFECFDF5),
                  fg: const Color(0xFF16A34A),
                ),
                _KpiCard(
                  title: "Need Attention",
                  value: stats["needAttention"]!,
                  icon: Icons.warning_amber_rounded,
                  bg: const Color(0xFFFFFBEB),
                  fg: const Color(0xFFD97706),
                ),
                _KpiCard(
                  title: "Pending Requests",
                  value: stats["pendingRequests"]!,
                  icon: Icons.inventory_2_rounded,
                  bg: const Color(0xFFEEF2FF),
                  fg: const Color(0xFF4F46E5),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ✅ PROJECTS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Projects",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All →",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            // ✅ PROJECT LIST (compact not cards)
            Column(
              children: projectStatus.map((p) => _ProjectRow(p: p)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ ALERT BANNER (like React)
class _AlertBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AlertBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE08A)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ✅ KPI CARD
class _KpiCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ✅ PROJECT ROW LIST (better than big cards)
class _ProjectRow extends StatelessWidget {
  final Map p;
  const _ProjectRow({required this.p});

  @override
  Widget build(BuildContext context) {
    final bool attention = p["attention"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: attention ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              attention ? Icons.error_rounded : Icons.check_rounded,
              color: attention ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 12),

          // main
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p["name"],
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  p["location"],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (p["progress"] as int) / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: attention ? const Color(0xFFF97316) : const Color(0xFF16A34A),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 10),

          // right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${p["progress"]}%",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: attention ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  attention ? "ATTENTION" : "ON TRACK",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.6,
                    color: attention ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
