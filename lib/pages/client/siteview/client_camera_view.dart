import 'package:flutter/material.dart';

class ClientCameraViewPage extends StatelessWidget {
  const ClientCameraViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: const Center(
        child: Text(
          "CAMERA VIEW",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
