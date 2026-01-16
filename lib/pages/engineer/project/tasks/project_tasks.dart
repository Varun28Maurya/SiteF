import 'package:flutter/material.dart';

class ProjectTasksPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectTasksPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Tasks\nProject: $projectName\nID: $projectId",
        textAlign: TextAlign.center,
      ),
    );
  }
}
