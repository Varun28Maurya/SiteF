import 'package:flutter/material.dart';

class ProjectChatPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectChatPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Chat\nProject: $projectName\nID: $projectId",
        textAlign: TextAlign.center,
      ),
    );
  }
}
