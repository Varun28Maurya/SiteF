import 'package:flutter/material.dart';

class ProjectMaterialsPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectMaterialsPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Materials\nProject: $projectName\nID: $projectId",
        textAlign: TextAlign.center,
      ),
    );
  }
}
