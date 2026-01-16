import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// MODELS
/// ============================================================
class ChatUser {
  final String id;
  final String role;
  final String name;

  const ChatUser({
    required this.id,
    required this.role,
    required this.name,
  });

  Map<String, dynamic> toJson() => {"id": id, "role": role, "name": name};

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json["id"] ?? "",
        role: json["role"] ?? "",
        name: json["name"] ?? "",
      );
}

class ChatMessage {
  final String id;
  final String projectId;
  final String projectName;
  final ChatUser sender;
  final ChatUser receiver;
  final String message;
  final String type; // TEXT, IMAGE later
  final DateTime createdAt;
  final String status; // SENT, DELIVERED, SEEN later

  const ChatMessage({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "projectId": projectId,
        "projectName": projectName,
        "sender": sender.toJson(),
        "receiver": receiver.toJson(),
        "message": message,
        "type": type,
        "createdAt": createdAt.toIso8601String(),
        "status": status,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json["id"],
        projectId: json["projectId"],
        projectName: json["projectName"] ?? "Project",
        sender: ChatUser.fromJson(json["sender"]),
        receiver: ChatUser.fromJson(json["receiver"]),
        message: json["message"] ?? "",
        type: json["type"] ?? "TEXT",
        createdAt: _parseDate(json["createdAt"]),
        status: json["status"] ?? "SENT",
      );
  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();

    // If already DateTime
    if (raw is DateTime) return raw;

    // If ISO string
    if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return DateTime.now();
      }
    }

    // If timestamp number
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }

    return DateTime.now();
  }
}

/// ============================================================
/// DATA LAYER (later replace with backend socket.io + API)
/// ============================================================
abstract class ChatRepository {
  Future<List<ChatMessage>> loadMessages();
  Future<void> saveMessages(List<ChatMessage> list);

  /// later: socket.io send
  Future<void> sendMessage(ChatMessage msg);
}

/// Local storage repo (SharedPreferences)
class LocalChatRepository implements ChatRepository {
  static const String storageKey = "chatMessages";

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    // default seeded messages if empty (same behavior as React)
    if (raw == null) {
      final seed = [
        ChatMessage(
          id: "msg-1",
          projectId: "proj-1",
          projectName: "Skyline Residency",
          sender: const ChatUser(
              id: "owner-1", role: "OWNER", name: "Project Owner"),
          receiver:
              const ChatUser(id: "eng-1", role: "ENGINEER", name: "Engineer"),
          message: "Hello Engineer, please provide the update.",
          type: "TEXT",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: "SENT",
        ),
      ];

      await saveMessages(seed);
      return seed;
    }

    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => ChatMessage.fromJson(e)).toList();
  }

  @override
  Future<void> saveMessages(List<ChatMessage> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        storageKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> sendMessage(ChatMessage msg) async {
    // ✅ placeholder for socket.io later
    // e.g. socket.emit("sendMessage", msg.toJson());
    return;
  }
}

/// ============================================================
/// UI PAGE
/// ============================================================
class OwnerChatPage extends StatefulWidget {
  const OwnerChatPage({super.key});

  @override
  State<OwnerChatPage> createState() => _OwnerChatPageState();
}

class _OwnerChatPageState extends State<OwnerChatPage> {
  final ChatRepository repo = LocalChatRepository();

  late final TextEditingController _controller;
  final ScrollController _scroll = ScrollController();

  late ChatUser authUser;

  List<ChatMessage> allMessages = [];
  String activeProjectId = "proj-1";
  bool showProjectListMobile = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    authUser = _loadAuthUser();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  ChatUser _loadAuthUser() {
    // later: you can load real "authUser" from SharedPreferences (like your AuthPage)
    // for now fallback as Engineer
    return const ChatUser(id: "eng-1", role: "ENGINEER", name: "Engineer");
  }

  Future<void> _load() async {
    final list = await repo.loadMessages();
    setState(() {
      allMessages = list;
    });

    // auto scroll bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  List<ChatMessage> get projectChats {
    // latest message per project (like reduce in React)
    final Map<String, ChatMessage> acc = {};
    for (final msg in allMessages) {
      final existing = acc[msg.projectId];
      if (existing == null || msg.createdAt.isAfter(existing.createdAt)) {
        acc[msg.projectId] = msg;
      }
    }
    final list = acc.values.toList();
    list.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt)); // newest project first
    return list;
  }

  List<ChatMessage> get activeMessages {
    final list =
        allMessages.where((m) => m.projectId == activeProjectId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  String get activeProjectName {
    final found =
        projectChats.where((p) => p.projectId == activeProjectId).toList();
    if (found.isNotEmpty) return found.first.projectName;
    return "Project Chat";
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = ChatMessage(
      id: "msg-${DateTime.now().millisecondsSinceEpoch}",
      projectId: activeProjectId,
      projectName: activeProjectName,
      sender: authUser,
      receiver:
          const ChatUser(id: "owner-1", role: "OWNER", name: "Project Owner"),
      message: text,
      type: "TEXT",
      createdAt: DateTime.now(),
      status: "SENT",
    );

    final updated = [...allMessages, msg];

    setState(() {
      allMessages = updated;
    });

    _controller.clear();

    await repo.saveMessages(updated);
    await repo.sendMessage(msg);

    // scroll after frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 768;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // LEFT PROJECT LIST
              if (isWide || showProjectListMobile)
                SizedBox(
                  width: isWide ? 280 : w,
                  child: _ProjectList(
                    projects: projectChats,
                    activeProjectId: activeProjectId,
                    onSelect: (pid) {
                      setState(() {
                        activeProjectId = pid;
                        showProjectListMobile = false;
                      });

                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _scrollToBottom());
                    },
                  ),
                ),

              // RIGHT CHAT AREA
              if (isWide || !showProjectListMobile)
                Expanded(
                  child: Column(
                    children: [
                      _ChatHeader(
                        title: "$activeProjectName Chat",
                        isWide: isWide,
                        onBackMobile: () =>
                            setState(() => showProjectListMobile = true),
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF1F5F9), // slate-50
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            controller: _scroll,
                            itemCount: activeMessages.length,
                            itemBuilder: (context, index) {
                              final msg = activeMessages[index];
                              final isMe = msg.sender.id == authUser.id;
                              return _MessageBubble(msg: msg, isMe: isMe);
                            },
                          ),
                        ),
                      ),
                      _ChatInput(
                        controller: _controller,
                        onSend: _send,
                        onCamera: () {
                          // TODO: attach camera later
                        },
                      ),
                    ],
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
/// COMPONENTS
/// ============================================================
class _ProjectList extends StatelessWidget {
  final List<ChatMessage> projects;
  final String activeProjectId;
  final ValueChanged<String> onSelect;

  const _ProjectList({
    required this.projects,
    required this.activeProjectId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              "Project Chats",
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final p = projects[index];
                final isActive = p.projectId == activeProjectId;
                return InkWell(
                  onTap: () => onSelect(p.projectId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange.shade100 : null,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: isActive
                            ? const BorderSide(color: Colors.orange, width: 4)
                            : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.projectName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
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

class _ChatHeader extends StatelessWidget {
  final String title;
  final bool isWide;
  final VoidCallback onBackMobile;

  const _ChatHeader({
    required this.title,
    required this.isWide,
    required this.onBackMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              onPressed: onBackMobile,
              icon: const Icon(Icons.chevron_left_rounded,
                  color: Colors.orange, size: 28),
            ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(18)),
            child: const Center(
              child: Text(
                "AM",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                    fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 2),
                const Text(
                  "● ONLINE",
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.phone, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          const Icon(Icons.videocam, color: Colors.orange, size: 20),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(msg.createdAt);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF0B3C5D) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 16 : 0),
              topRight: Radius.circular(isMe ? 0 : 16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  msg.sender.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange),
                ),
              Text(
                msg.message,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withOpacity(0.45)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCamera;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onCamera,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.camera_alt, color: Colors.orange, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: "Type update...",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.orange.withOpacity(0.28), blurRadius: 10)
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
    );
  }
}
