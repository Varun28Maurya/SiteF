import 'package:flutter/material.dart';
import '../../../routes.dart';

class ClientSiteViewPage extends StatelessWidget {
  const ClientSiteViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // MAP (Full Width)
        _BigNavCard(
          title: "MAP",
          icon: Icons.map_rounded,
          height: 180,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.clientMapView);
          },
        ),

        const SizedBox(height: 16),

        // 2D + 3D (Row)
        Row(
          children: [
            Expanded(
              child: _BigNavCard(
                title: "2D",
                icon: Icons.grid_view_rounded,
                height: 140,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.client2DView);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BigNavCard(
                title: "3D",
                icon: Icons.view_in_ar_rounded,
                height: 140,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.client3DView);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // CAMERA (Full Width)
        _BigNavCard(
          title: "CAMERA",
          icon: Icons.camera_alt_rounded,
          height: 180,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.clientCameraView);
          },
        ),
      ],
    );
  }
}

class _BigNavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double height;
  final VoidCallback onTap;

  const _BigNavCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
