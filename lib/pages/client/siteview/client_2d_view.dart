import 'package:flutter/material.dart';

class Client2DViewPage extends StatelessWidget {
  const Client2DViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("2D View")),
      body: const Center(
        child: Text(
          "2D VIEW",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
