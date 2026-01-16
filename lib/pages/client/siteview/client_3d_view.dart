import 'package:flutter/material.dart';

class Client3DViewPage extends StatelessWidget {
  const Client3DViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D View")),
      body: const Center(
        child: Text(
          "3D VIEW",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
