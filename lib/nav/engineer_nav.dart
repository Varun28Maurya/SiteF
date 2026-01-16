import 'package:flutter/material.dart';
import '../routes.dart';
import '../layout/app_header.dart';
import '../components/logout.dart';
import '../components/assistant_fab.dart';
// Engineer Pages
import '../pages/engineer/dashboard/engineer_dashboard.dart';
import '../pages/engineer/projects/engineer_projects.dart';
import '../pages/engineer/tasks/engineer_tasks.dart';
import '../pages/engineer/materials_funds/engineer_materials_funds.dart';
import '../pages/engineer/chat/engineer_chat.dart';

class EngineerNav extends StatefulWidget {
  final int initialIndex;
  const EngineerNav({super.key, this.initialIndex = 0});
  

  @override
  State<EngineerNav> createState() => _EngineerNavState();
}

class _EngineerNavState extends State<EngineerNav> {
  bool isOffline = false;
  late int currentIndex;

  final List<Widget> pages = const [
    EngineerDashboardPage(),
    EngineerProjectsPage(),
    EngineerTasksPage(),
    EngineerMaterialsFundsPage(),
    EngineerChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _goToIndex(int index) {
    // ✅ Smooth switching
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppHeader(
        isOffline: isOffline,
        onToggleOffline: () => setState(() => isOffline = !isOffline),
        onReadAloud: () {},
        onNotifications: () {},
        onProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
        onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
        onLogout: () async => await logout(context),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),

      floatingActionButton: const AssistantFab(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _goToIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: "Dashboard"),
          NavigationDestination(icon: Icon(Icons.map_rounded), label: "Projects"),
          NavigationDestination(icon: Icon(Icons.task_alt), label: "Tasks"),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: "Materials",
          ),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}
