import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastScanScreen extends StatefulWidget {
  const LastScanScreen({Key? key}) : super(key: key);

  @override
  State<LastScanScreen> createState() => _LastScanScreenState();
}

class _LastScanScreenState extends State<LastScanScreen> {
  File? _lastImage;

  @override
  void initState() {
    super.initState();
    _loadLastImage();
  }

  Future<void> _loadLastImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('last_scan_image');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _lastImage = File(imagePath);
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage =
          await File(pickedImage.path).copy('${directory.path}/last_scan.jpg');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_scan_image', savedImage.path);

      setState(() {
        _lastImage = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Last Plant Scan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Last Scanned Plant",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _lastImage != null
                ? Image.file(_lastImage!, height: 250)
                : const Text("No previous scan found."),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickAndSaveImage,
              icon: const Icon(Icons.history),
              label: const Text("Reload Last Image"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Add your recheck prediction function here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Rerunning detection...")),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Recheck Plant Disease"),
            ),
          ],
        ),
      ),
    );
  }
}
