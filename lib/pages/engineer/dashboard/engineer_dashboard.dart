import 'package:flutter/material.dart';

class EngineerDashboardPage extends StatefulWidget {
  const EngineerDashboardPage({super.key});

  @override
  State<EngineerDashboardPage> createState() => _EngineerDashboardPageState();
}

class _EngineerDashboardPageState extends State<EngineerDashboardPage> {
  final String engineerId = "eng-1";

  List<Map<String, dynamic>> projects = [
    {
      "id": "p1",
      "name": "Skyline Residency",
      "engineerId": "eng-1",
      "dpr": false,
      "materialsCount": 5
    },
    {
      "id": "p2",
      "name": "Green Valley Villas",
      "engineerId": "eng-1",
      "dpr": true,
      "materialsCount": 1
    }
  ];

  List<Map<String, dynamic>> get dashboardProjects {
    return projects
        .where((p) => p["engineerId"] == engineerId)
        .map((p) {
      return {
        ...p,
        "status": (!p["dpr"] || p["materialsCount"] > 3)
            ? "Attention Needed"
            : "On Track"
      };
    }).toList();
  }

  int get onTrack =>
      dashboardProjects.where((p) => p["status"] == "On Track").length;
  int get attention =>
      dashboardProjects.where((p) => p["status"] == "Attention Needed").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text("Engineer Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.access_time, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Shift started at 08:30 AM",
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                ],
              ),
              const SizedBox(height: 20),

              /// UTILIZATION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4338CA)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("UTILIZATION",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    const Text("92%",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: 0.92,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// STATS GRID
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                      title: "On Track",
                      value: onTrack.toString(),
                      icon: Icons.check_circle,
                      bg: const Color(0xFFD1FAE5),
                      fg: const Color(0xFF059669)),
                  StatCard(
                      title: "Attention",
                      value: attention.toString(),
                      icon: Icons.warning,
                      bg: const Color(0xFFFFFBEB),
                      fg: const Color(0xFFD97706)),
                  StatCard(
                      title: "Projects",
                      value: dashboardProjects.length.toString(),
                      icon: Icons.grid_view,
                      bg: const Color(0xFFDBEAFE),
                      fg: const Color(0xFF2563EB)),
                  StatCard(
                      title: "Quality",
                      value: "✓",
                      icon: Icons.check_circle,
                      bg: const Color(0xFFDCFCE7),
                      fg: const Color(0xFF16A34A)),
                ],
              ),

              const SizedBox(height: 24),

              /// ATTENTION RADAR
              const Text("🚨 Attention Radar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200)),
                child: dashboardProjects.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No assigned projects",
                            style: TextStyle(color: Colors.grey)),
                      )
                    : Column(
                        children: dashboardProjects.map((p) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p["name"],
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          const Text("DPR not submitted today",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey))
                                        ]),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFD1FAE5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text("LOW RISK",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF047857))),
                                    )
                                  ],
                                ),
                              ),
                              if (p != dashboardProjects.last)
                                Divider(height: 1, color: Colors.grey.shade200)
                            ],
                          );
                        }).toList(),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bg;
  final Color fg;

  const StatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.bg,
      required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }
}