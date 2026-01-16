import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ProjectDashboardPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDashboardPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDashboardPage> createState() => _ProjectDashboardPageState();
}

class _ProjectDashboardPageState extends State<ProjectDashboardPage> {
  bool checkingLocation = false;
  String gpsStatus = "NOT_VERIFIED";
  int? distanceFromSite;
  bool dprSubmitted = false;

  /// ✅ demo site coords (later you will fetch by projectId from DB/API)
  final double siteLat = 19.0760;
  final double siteLng = 72.8777;
  final int siteRadius = 200; // meters

  Map<String, dynamic> attendance = {
    "self": false,
    "workers": 18,
  };

  /* ================= DISTANCE ================= */
  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * (2 * atan2(sqrt(a), sqrt(1 - a)));
  }

  /* ================= CHECK-IN ================= */
  Future<void> handleSelfCheckIn() async {
    if (attendance["self"] || checkingLocation) return;

    setState(() => checkingLocation = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final dist = _distance(
        pos.latitude,
        pos.longitude,
        siteLat,
        siteLng,
      );

      if (dist <= siteRadius) {
        setState(() {
          attendance["self"] = true;
          gpsStatus = "VERIFIED";
          distanceFromSite = dist.round();
        });
      } else {
        setState(() => gpsStatus = "FAILED");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You are ${dist.round()}m away from site")),
        );
      }
    } catch (_) {
      setState(() => gpsStatus = "FAILED");
    }

    setState(() => checkingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ PROJECT TITLE HEADER
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.projectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// ATTENDANCE + DPR
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              children: [
                _attendanceCard(),
                _dprCard(),
              ],
            ),

            const SizedBox(height: 20),

            /// URGENT MATERIALS
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "URGENT MATERIALS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Raise request for cement, steel, etc.",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Raise Request"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: const Color(0xff0B3C5D),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= WIDGETS ================= */

  Widget _attendanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ATTENDANCE STATUS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: checkingLocation ? null : handleSelfCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: attendance["self"]
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      foregroundColor:
                          attendance["self"] ? Colors.green : Colors.grey,
                      minimumSize: const Size(0, 80),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        checkingLocation
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : const Icon(Icons.check_circle, size: 32),
                        const SizedBox(height: 6),
                        Text(attendance["self"] ? "Checked In" : "Self Check-in"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xff0B3C5D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${attendance["workers"]}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "WORKERS PRESENT",
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.navigation,
                  size: 14,
                  color: gpsStatus == "VERIFIED"
                      ? Colors.green
                      : gpsStatus == "FAILED"
                          ? Colors.red
                          : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  gpsStatus == "VERIFIED"
                      ? "GPS Verified • ${distanceFromSite}m"
                      : gpsStatus == "FAILED"
                          ? "GPS verification failed"
                          : "GPS not verified",
                  style: const TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _dprCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xff0B3C5D),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DAILY PROGRESS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Capture today’s work & photos",
              style: TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (!attendance["self"] || dprSubmitted)
                  ? null
                  : () => setState(() => dprSubmitted = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dprSubmitted ? Colors.green : Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                dprSubmitted ? "DPR Submitted" : "Start DPR",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          ],
        ),
      ),
    );
  }
}
