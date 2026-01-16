import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProposalPage extends StatefulWidget {
  const ProposalPage({super.key});

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  final ImagePicker _picker = ImagePicker();

  /* ================= SOCIETY INFO ================= */
  String societyName = '';
  String building = '';
  String location = '';
  DateTime? inspectionDate;
  File? societyImage;

  /* ================= DEFECTS ================= */
  List<Map<String, dynamic>> defects = [];

  void addDefect() {
    setState(() {
      defects.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'image': null,
        'defectType': '',
        'severity': '',
        'notes': '',
      });
    });
  }

  void removeDefect(int id) {
    setState(() {
      defects.removeWhere((d) => d['id'] == id);
    });
  }

  /* ================= IMAGE PICKER ================= */
  Future<void> pickImage(Function(File) onPicked) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) onPicked(File(file.path));
  }

  /* ================= CONDITION LOGIC ================= */
  String getConditionStatus() {
    if (defects.isEmpty) return 'PENDING';
    if (defects.any((d) => d['severity'] == 'Immediate Repair')) {
      return 'IMMEDIATE ATTENTION REQUIRED';
    }
    if (defects.any((d) => d['severity'] == 'Medium')) {
      return 'MODERATE';
    }
    return 'GOOD';
  }

  String getSummary() {
    if (defects.isEmpty) {
      return 'No inspection data available. Please add defects to generate report.';
    }

    final critical = defects.where((d) => d['severity'] == 'Immediate Repair').length;

    return '''
This property inspection revealed ${defects.length} structural observations.
${critical > 0 ? '$critical critical defect(s) require immediate attention.' : ''}
Regular maintenance and timely repairs will ensure long-term durability and safety.
Professional structural assessment is recommended.
''';
  }

  /* ================= PDF ================= */
  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            societyName,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Inspection Report'),
          pw.SizedBox(height: 20),
          pw.Text('Condition: ${getConditionStatus()}'),
          pw.SizedBox(height: 20),
          pw.Text(getSummary()),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text('Structural Inspection Report'),
        actions: [
          ElevatedButton.icon(
            onPressed: societyName.isEmpty ? null : generatePDF,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* ================= SOCIETY INFO ================= */
            _card(
              title: 'Society Information',
              child: Column(
                children: [
                  _input('Society Name *', onChanged: (v) => societyName = v),
                  const SizedBox(height: 12),
                  _imagePicker(
                    label: 'Building Image',
                    image: societyImage,
                    onPick: () => pickImage((f) {
                      setState(() => societyImage = f);
                    }),
                  ),
                  const SizedBox(height: 12),
                  _input('Building / Wing', onChanged: (v) => building = v),
                  const SizedBox(height: 12),
                  _input('Location', onChanged: (v) => location = v),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      inspectionDate == null
                          ? 'Inspection Date'
                          : DateFormat.yMMMMd('en_IN').format(inspectionDate!),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDate: DateTime.now(),
                      );
                      if (date != null) setState(() => inspectionDate = date);
                    },
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /* ================= DEFECTS ================= */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Defect Observations (${defects.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: addDefect,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Defect'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (defects.isEmpty)
              const Text('No defects added yet')
            else
              ...defects.map((d) => _defectCard(d)),

            const SizedBox(height: 20),

            /* ================= SUMMARY ================= */
            _card(
              title: 'Final Summary',
              child: Text(getSummary()),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= WIDGET HELPERS ================= */

  Widget _card({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child
        ]),
      ),
    );
  }

  Widget _input(String label, {required Function(String) onChanged}) {
    return TextField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: onChanged,
    );
  }

  Widget _imagePicker({
    required String label,
    required File? image,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: image == null
                ? const Center(child: Icon(Icons.upload))
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _defectCard(Map<String, dynamic> defect) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _imagePicker(
              label: 'Defect Image',
              image: defect['image'],
              onPick: () => pickImage((f) {
                setState(() => defect['image'] = f);
              }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: defect['defectType'].isEmpty ? null : defect['defectType'],
              items: const [
                'Crack',
                'Seepage',
                'Waterproofing Failure',
                'Structural Damage',
                'Terrace / Parapet Issue'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => defect['defectType'] = v ?? ''),
              decoration: const InputDecoration(labelText: 'Defect Type'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: defect['severity'].isEmpty ? null : defect['severity'],
              items: const ['Low', 'Medium', 'Immediate Repair']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => defect['severity'] = v ?? ''),
              decoration: const InputDecoration(labelText: 'Severity'),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
              onChanged: (v) => defect['notes'] = v,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => removeDefect(defect['id']),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Remove Defect', style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }
}