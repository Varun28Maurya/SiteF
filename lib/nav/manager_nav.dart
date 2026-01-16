import 'package:flutter/material.dart';
import '../routes.dart';
import '../layout/app_header.dart';
import '../components/logout.dart';
import '../components/assistant_fab.dart';
// Manager pages
import '../pages/manager/dashboard/manager_dashboard.dart';
import '../pages/manager/projects/manager_projects.dart';
import '../pages/manager/tasks/manager_tasks.dart';
import '../pages/manager/materials_funds/manager_materials_funds.dart';
import '../pages/manager/chat/manager_chat.dart';

class ManagerNav extends StatefulWidget {
  final int initialIndex;
  const ManagerNav({super.key, this.initialIndex = 0});

  @override
  State<ManagerNav> createState() => _ManagerNavState();
}

class _ManagerNavState extends State<ManagerNav> {
  bool isOffline = false;
  late int currentIndex;

  final List<Widget> pages = const [
    ManagerDashboardPage(),
    ManagerProjectsPage(),
    ManagerTasksPage(),
    ManagerMaterialsFundsPage(),
    ManagerChatPage(),
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
          NavigationDestination(icon: Icon(Icons.apartment), label: "Projects"),
          NavigationDestination(icon: Icon(Icons.task_alt), label: "Tasks"),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: "Materials"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}
