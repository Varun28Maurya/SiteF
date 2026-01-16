import 'package:flutter/material.dart';
import '../routes.dart';
import '../layout/app_header.dart';
import '../components/logout.dart';

// Client pages
import '../pages/client/overview/client_overview.dart';
import '../pages/client/siteview/client_siteview.dart';
import '../pages/client/updates/client_updates.dart';
import '../pages/client/docs/client_docs.dart';
import '../pages/client/chat/client_chat.dart';

class ClientNav extends StatefulWidget {
  final int initialIndex;
  const ClientNav({super.key, this.initialIndex = 0});

  @override
  State<ClientNav> createState() => _ClientNavState();
}

class _ClientNavState extends State<ClientNav> {
  bool isOffline = false;
  late int currentIndex;

  final List<Widget> pages = const [
    ClientOverviewPage(),
    ClientSiteViewPage(),
    ClientUpdatesPage(),
    ClientDocsPage(),
    ClientChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _goToIndex(int index) {
    // ✅ smooth switching
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

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _goToIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: "Overview"),
          NavigationDestination(icon: Icon(Icons.map_rounded), label: "SiteView"),
          NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: "Updates"),
          NavigationDestination(icon: Icon(Icons.folder_rounded), label: "Docs"),
          NavigationDestination(icon: Icon(Icons.chat_rounded), label: "Chat"),
        ],
      ),
    );
  }
}
