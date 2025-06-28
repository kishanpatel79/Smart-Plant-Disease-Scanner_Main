import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';
import '../services/disease_database.dart';
import '../models/disease.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final Uint8List? imageBytes;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    this.imageBytes,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ClassifierService _classifier = ClassifierService();
  final DiseaseDatabase _diseaseDb = DiseaseDatabase();
  bool _isAnalyzing = true;
  String _diseaseName = '';
  Disease? _diseaseInfo;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Get disease prediction
      final prediction = await _classifier.classifyImage(widget.imagePath);

      // Get disease information
      if (prediction != null) {
        final diseaseInfo = await _diseaseDb.getDiseaseInfo(prediction);

        setState(() {
          _diseaseName = prediction;
          _diseaseInfo = diseaseInfo;
          _isAnalyzing = false;
        });
      }

      
    } catch (e) {
      setState(() {
        _diseaseName = 'Error: $e';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Results'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image display
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: kIsWeb && widget.imageBytes != null
                  ? Image.memory(
                      widget.imageBytes!,
                      fit: BoxFit.contain,
                    )
                  : widget.imagePath.isNotEmpty
                      ? Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Text(
                            'No image available',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
            ),

            // Results section
            _isAnalyzing
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing leaf image...'),
                      ],
                    ),
                  )
                : _buildResultsSection(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Scan Another Plant'),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_diseaseInfo == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No disease information available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Identified Disease',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _diseaseName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description
          _buildSection(
            'Description',
            _diseaseInfo!.description,
            Icons.info_outline,
          ),

          // Symptoms
          _buildSection(
            'Symptoms',
            _diseaseInfo!.symptoms,
            Icons.sick,
          ),

          // Treatment
          _buildSection(
            'Treatment',
            _diseaseInfo!.treatment,
            Icons.healing,
          ),

          // Prevention
          _buildSection(
            'Prevention',
            _diseaseInfo!.prevention,
            Icons.shield,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content),
        const SizedBox(height: 16),
      ],
    );
  }
}
