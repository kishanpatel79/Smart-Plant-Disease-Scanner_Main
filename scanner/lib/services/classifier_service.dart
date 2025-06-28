import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'disease_database.dart';

class ClassifierService {
  static const String LABELS_PATH = 'assets/labels.txt';

  List<String> _labels = [];
  bool _isModelLoaded = false;

  // Initialize singleton
  static final ClassifierService _instance = ClassifierService._internal();

  factory ClassifierService() {
    return _instance;
  }

  ClassifierService._internal();

  Future<void> _loadLabels() async {
    try {
      if (_isModelLoaded) return;

      try {
        final labelsData = await rootBundle.loadString(LABELS_PATH);
        _labels = labelsData.split('\n');
      } catch (e) {
        print('Error loading labels: $e');
        // Load default set of labels if file isn't available
        _labels = await DiseaseDatabase().getAvailableDiseases();
      }

      _isModelLoaded = true;
    } catch (e) {
      print('Error in model initialization: $e');
      _labels = await DiseaseDatabase().getAvailableDiseases();
      _isModelLoaded = true;
    }
  }

  Future<String?> classifyImage(String imagePath) async {
    // Load labels if not already loaded
    if (!_isModelLoaded) {
      await _loadLabels();
    }

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    try {
      Tflite.close();
      String? res = await Tflite.loadModel(
          model: "assets/Tanmay_final_model.tflite",
          labels: "assets/Labels1.txt",
          numThreads: 1, // defaults to 1
          isAsset:
              true, // defaults to true, set to false to load resources outside assets
          useGpuDelegate:
              false // defaults to false, set to true to use GPU delegate
          );
      print("32453456465475675");
      print(res);

      var recognitions = await Tflite.runModelOnImage(
          path: imagePath, // required
          imageMean: 0.0, // defaults to 117.0
          imageStd: 255.0, // defaults to 1.0
          numResults: 2, // defaults to 5
          threshold: 0.2, // defaults to 0.1
          asynch: true // defaults to true
          );

      print("Raw recognitions: $recognitions"); // Log the raw output

// Safely check and handle the type.
      List<Map<String, dynamic>> safeRecognitions = [];

      if (recognitions is List) {
       safeRecognitions = recognitions.map((e) {
          // Cast the map properly ensuring the keys are String and the values are dynamic
          return Map<String, dynamic>.from(e as Map<Object?, Object?>);
        }).toList();
      }

      print("Safe Recognitions: $safeRecognitions");

      return getHighestConfidenceLabel(safeRecognitions);
    } catch (e) {
      print(e);
    }
    return null;

    // // For web and development, use mock prediction
    // return _getMockPrediction();
  }

  String getHighestConfidenceLabel(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) return '';

    // Find the map with the highest confidence
    Map<String, dynamic> highest =
        predictions.reduce((a, b) => a['confidence'] > b['confidence'] ? a : b);

    return highest['label'];
  }

  // For development/testing and web platform
  String _getMockPrediction() {
    final diseaseNames = [
      'Tomato Late Blight',
      'Apple Black Rot',
      'Grape Black Rot',
      'Tomato Early Blight',
      'Apple Scab',
      'Strawberry Leaf Scorch',
      'Corn Common Rust',
      'Peach Bacterial Spot',
      'Potato Late Blight',
      'Tomato Mosaic Virus',
    ];

    return diseaseNames[Random().nextInt(diseaseNames.length)];
  }
}
