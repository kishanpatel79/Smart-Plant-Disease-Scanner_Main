import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'results_screen.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (pickedFile == null) {
        return;
      }

      if (kIsWeb) {
        // Handle web platform
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        // Handle mobile platform
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _processImage() {
    if (_imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Navigate to results screen with a delay to show processing
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imagePath: _imageFile?.path ?? '',
            imageBytes: _webImage,
          ),
        ),
      ).then((_) {
        setState(() {
          _isProcessing = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : _imageFile != null || _webImage != null
                      ? kIsWeb 
                          ? Image.memory(_webImage!)
                          : Image.file(_imageFile!)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.photo_library,
                              size: 100,
                              color: Colors.green,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Capture or select a leaf image',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'The app will analyze the image and identify\nany diseases affecting your plant',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _getImage(ImageSource.camera),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green.shade700,
                    ),
                    onPressed: (_imageFile != null || _webImage != null) && !_isProcessing
                        ? _processImage
                        : null,
                    child: const Text(
                      'Scan for Diseases',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
