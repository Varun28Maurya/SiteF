import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../nav/engineer_project_nav.dart';

/// ============================================================
/// MODEL
/// ============================================================
class ProjectModel {
  final String id;
  final String name;
  final String location;
  final String type;
  final String roleUserId; // engineerId / managerId
  final String status; // On Track / Attention Needed
  final int materialsPending;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.roleUserId,
    required this.status,
    required this.materialsPending,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "type": type,
        "roleUserId": roleUserId,
        "status": status,
        "materialsPending": materialsPending,
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json["id"].toString(),
        name: json["name"] ?? "",
        location: json["location"] ?? "",
        type: json["type"] ?? "Residential",
        roleUserId: json["roleUserId"] ?? "",
        status: json["status"] ?? "On Track",
        materialsPending: (json["materialsPending"] ?? 0) as int,
      );
}

/// ============================================================
/// PAGE (REUSABLE FOR ENGINEER / MANAGER)
/// ============================================================
class EngineerProjectsPage extends StatefulWidget {
  final String role; // ENGINEER / MANAGER
  final String userId; // eng-1 / mgr-1

  const EngineerProjectsPage({
    super.key,
    this.role = "ENGINEER",
    this.userId = "eng-1",
  });

  @override
  State<EngineerProjectsPage> createState() => _EngineerProjectsPageState();
}

class _EngineerProjectsPageState extends State<EngineerProjectsPage> {
  final String storageKey = "projects"; // like React localStorage
  final TextEditingController searchCtrl = TextEditingController();

  List<ProjectModel> projects = [];
  bool loading = true;

  /// ✅ Seed fallback (your projects.json)
  List<ProjectModel> seedProjects() {
    return [
      ProjectModel(
        id: "proj-1",
        name: "Skyline Residency",
        location: "Worli, Mumbai",
        type: "Residential",
        roleUserId: widget.userId,
        status: "On Track",
        materialsPending: 2,
      ),
      ProjectModel(
        id: "proj-2",
        name: "Green Valley Villas",
        location: "Sector 45, Gurgaon",
        type: "Residential",
        roleUserId: widget.userId,
        status: "Attention Needed",
        materialsPending: 5,
      ),
      ProjectModel(
        id: "proj-3",
        name: "Industrial Park Phase 2",
        location: "Pune, Maharashtra",
        type: "Industrial",
        roleUserId: widget.userId,
        status: "On Track",
        materialsPending: 0,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    if (raw == null) {
      final seed = seedProjects();
      await prefs.setString(
        storageKey,
        jsonEncode(seed.map((e) => e.toJson()).toList()),
      );
      projects = seed;
    } else {
      final decoded = jsonDecode(raw) as List;
      projects = decoded.map((e) => ProjectModel.fromJson(e)).toList();
    }

    setState(() => loading = false);
  }

  Future<void> _saveProjects(List<ProjectModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  List<ProjectModel> get filtered {
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return projects;

    return projects.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _removeProject(String id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Remove Project"),
            content: const Text("Remove this project?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Remove"),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    final updated = projects.where((p) => p.id != id).toList();

    setState(() => projects = updated);
    await _saveProjects(updated);
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AddProjectModal(
        onClose: () => Navigator.pop(context),
        onAdd: (proj) async {
          final updated = [...projects, proj];
          setState(() => projects = updated);
          await _saveProjects(updated);
        },
        userId: widget.userId,
      ),
    );
  }

  int _gridCount(double width) {
    if (width >= 1024) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "My Projects",
                      style: TextStyle(
                        fontSize: w >= 480 ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _openAddModal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      "Add",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),

              /// SEARCH
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Search projects...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// GRID
              Expanded(
                child: GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridCount(w),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return _ProjectCard(
                      project: p,
                      onRemove: () => _removeProject(p.id),
                      onEnter: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => EngineerProjectNav(
                              projectId: p.id,
                              projectName: p.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// PROJECT CARD
/// ============================================================
class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onRemove;
  final VoidCallback onEnter;

  const _ProjectCard({
    required this.project,
    required this.onRemove,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final bool attention = project.status == "Attention Needed";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 6,
            color:
                attention ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Delete
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                      )
                    ],
                  ),

                  const SizedBox(height: 2),

                  /// Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          project.location,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// DPR + Materials
                  Row(
                    children: [
                      Expanded(
                        child: _MiniInfoBox(
                          icon: Icons.verified_rounded,
                          label: "DPR: Done",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniInfoBox(
                          icon: Icons.inventory_2_rounded,
                          label: "Mat: ${project.materialsPending}",
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// Enter site
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B3C5D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: onEnter,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text(
                        "Enter Site",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MiniInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfoBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F172A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// ADD PROJECT MODAL (BOTTOM SHEET)
/// ============================================================
class _AddProjectModal extends StatefulWidget {
  final VoidCallback onClose;
  final Future<void> Function(ProjectModel project) onAdd;
  final String userId;

  const _AddProjectModal({
    required this.onClose,
    required this.onAdd,
    required this.userId,
  });

  @override
  State<_AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<_AddProjectModal> {
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  String type = "";

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final location = locationCtrl.text.trim();

    if (name.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final newProject = ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      location: location,
      type: type.isEmpty ? "Residential" : type,
      roleUserId: widget.userId,
      status: "On Track",
      materialsPending: 0,
    );

    await widget.onAdd(newProject);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        18,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),

          /// Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  "New Project",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 8),

          /// Form
          _field(controller: nameCtrl, hint: "Project / Site Name"),
          const SizedBox(height: 12),
          _field(controller: locationCtrl, hint: "Location (City / Area)"),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: type.isEmpty ? null : type,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              hintText: "Project Type",
            ),
            items: const [
              DropdownMenuItem(
                  value: "Residential", child: Text("Residential")),
              DropdownMenuItem(value: "Commercial", child: Text("Commercial")),
              DropdownMenuItem(value: "Industrial", child: Text("Industrial")),
            ],
            onChanged: (v) => setState(() => type = v ?? ""),
          ),

          const SizedBox(height: 18),

          /// Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _submit,
              child: const Text(
                "ADD PROJECT",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _field(
      {required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}
