import 'package:flutter/material.dart';

class ManagerTasksPage extends StatefulWidget {
  const ManagerTasksPage({super.key});

  @override
  State<ManagerTasksPage> createState() => _ManagerTasksPageState();
}

class _ManagerTasksPageState extends State<ManagerTasksPage> {
  String filter = "ALL";

  List<Map<String, dynamic>> tasks = [
    {
      "id": "T1",
      "title": "Column Shuttering – Block A",
      "dueDate": "2026-01-18",
      "priority": "HIGH",
      "status": "PENDING",
      "projectName": "Tower A",
      "assignedTo": "eng-1"
    },
    {
      "id": "T2",
      "title": "Beam Reinforcement",
      "dueDate": "2026-01-19",
      "priority": "MEDIUM",
      "status": "PENDING",
      "projectName": "Tower A",
      "assignedTo": "eng-1"
    },
    {
      "id": "T3",
      "title": "Slab Casting",
      "dueDate": "2026-01-20",
      "priority": "LOW",
      "status": "COMPLETED",
      "projectName": "Tower B",
      "assignedTo": "eng-1"
    },
  ];

  void markDone(String id) {
    setState(() {
      for (var t in tasks) {
        if (t["id"] == id) {
          t["status"] = "COMPLETED";
        }
      }
    });
  }

  Map<String, List<Map<String, dynamic>>> get groupedTasks {
    final filtered = tasks.where((t) {
      if (filter == "ALL") return true;
      return t["status"] == filter;
    });

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var t in filtered) {
      grouped.putIfAbsent(t["projectName"], () => []);
      grouped[t["projectName"]]!.add(t);
    }
    return grouped;
  }

  Color priorityBg(String p) {
    if (p == "HIGH") return const Color(0xFFFEE2E2);
    if (p == "MEDIUM") return const Color(0xFFFEF3C7);
    return const Color(0xFFD1FAE5);
  }

  Color priorityText(String p) {
    if (p == "HIGH") return const Color(0xFFB91C1C);
    if (p == "MEDIUM") return const Color(0xFFB45309);
    return const Color(0xFF047857);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              "GLOBAL TASKS",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            const Text(
              "Across all assigned sites",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),

            const SizedBox(height: 16),

            // FILTERS
            Row(
              children: ["ALL", "PENDING", "COMPLETED"].map((t) {
                final active = filter == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          active ? const Color(0xFF0B3C5D) : Colors.white,
                      foregroundColor:
                          active ? Colors.white : Colors.grey[600],
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => setState(() => filter = t),
                    child: Text(
                      t,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // TASK GROUPS
            ...groupedTasks.entries.map((entry) {
              final projectName = entry.key;
              final projectTasks = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grid_view, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        projectName.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...projectTasks.map((task) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 4,
                              color: Colors.black12,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task["title"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(task["dueDate"],
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priorityBg(task["priority"]),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: priorityBg(task["priority"])),
                                ),
                                child: Text(
                                  task["priority"],
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: priorityText(task["priority"])),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    task["status"].replaceAll("_", " "),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                              task["status"] != "COMPLETED"
                                  ? ElevatedButton(
                                      onPressed: () => markDone(task["id"]),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14))),
                                      child: const Text("MARK DONE",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900)),
                                    )
                                  : Row(
                                      children: const [
                                        Icon(Icons.check_circle,
                                            size: 16, color: Colors.green),
                                        SizedBox(width: 6),
                                        Text("DONE",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.green))
                                      ],
                                    )
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList()
                ],
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}