import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/disease.dart';

class DiseaseDatabase {
  static const String DATABASE_PATH = 'assets/diseases.json';
  Map<String, Disease> _diseases = {};
  bool _isLoaded = false;
  
  // Initialize singleton
  static final DiseaseDatabase _instance = DiseaseDatabase._internal();
  
  factory DiseaseDatabase() {
    return _instance;
  }
  
  DiseaseDatabase._internal();
  
  Future<void> _loadDatabase() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString(DATABASE_PATH);
      final List<dynamic> diseaseList = json.decode(jsonString);
      
      for (var diseaseData in diseaseList) {
        final disease = Disease.fromJson(diseaseData);
        _diseases[disease.name] = disease;
      }
      
      _isLoaded = true;
    } catch (e) {
      print('Error loading disease database: $e');
      // Create mock database for development
      _createMockDatabase();
      _isLoaded = true;
    }
  }
  
  void _createMockDatabase() {
    final mockDiseases = [
      Disease(
        name: 'Tomato Late Blight',
        description: 'A serious disease caused by the fungus-like organism Phytophthora infestans. It affects tomatoes, potatoes, and other members of the Solanaceae family.',
        symptoms: 'Dark, water-soaked spots on leaves that quickly enlarge to form purple-brown, oily-looking blotches. White fungal growth may appear on the undersides of leaves. Infected fruits develop dark, firm lesions.',
        treatment: 'Remove and destroy infected plant parts. Apply copper-based fungicides or specific late blight fungicides. In severe cases, remove entire plants to prevent spread.',
        prevention: 'Use resistant varieties. Provide good air circulation by proper spacing. Water at the base of plants. Apply preventative fungicides during humid weather. Practice crop rotation.',
      ),
      Disease(
        name: 'Apple Black Rot',
        description: 'A fungal disease caused by Botryosphaeria obtusa that affects apple trees and fruit.',
        symptoms: 'Circular lesions on leaves with purple edges and brown centers. Fruit develops small, dark spots that enlarge into sunken, black rotted areas with concentric rings.',
        treatment: 'Remove and destroy infected fruit and cankers. Prune out dead wood. Apply fungicides during the growing season.',
        prevention: 'Maintain tree vigor with proper fertilization. Prune and destroy dead wood. Control insects that create entry wounds. Apply protective fungicides starting at pink bud stage.',
      ),
      Disease(
        name: 'Grape Black Rot',
        description: 'A fungal disease caused by Guignardia bidwellii that affects grape leaves, shoots, and fruit.',
        symptoms: 'Small, reddish-brown spots on leaves that enlarge and develop tan centers with dark borders. Infected fruits initially show white dots, then develop into brown spots before the entire grape shrivels into a black mummy.',
        treatment: 'Remove mummified fruits and infected leaves. Apply fungicides starting just before bloom and continuing through fruit development.',
        prevention: 'Prune vines to improve air circulation. Remove wild grapes from nearby areas. Maintain a regular fungicide spray program in susceptible areas.',
      ),
      Disease(
        name: 'Tomato Early Blight',
        description: 'A fungal disease caused by Alternaria solani that affects tomatoes and potatoes.',
        symptoms: 'Dark brown spots with concentric rings on lower leaves first, resembling a target board. Leaves may yellow around spots before turning brown and falling off.',
        treatment: 'Remove and destroy infected leaves. Apply fungicides labeled for early blight control.',
        prevention: 'Mulch around plants to prevent soil splash. Avoid overhead watering. Use crop rotation. Choose resistant varieties when available.',
      ),
    ];
    
    for (var disease in mockDiseases) {
      _diseases[disease.name] = disease;
    }
  }
  
  Future<List<String>> getAvailableDiseases() async {
    await _loadDatabase();
    return _diseases.keys.toList();
  }
  
  Future<Disease> getDiseaseInfo(String diseaseName) async {
    await _loadDatabase();
    
    if (_diseases.containsKey(diseaseName)) {
      return _diseases[diseaseName]!;
    } else {
      // Return a default disease info
      return Disease(
        name: diseaseName,
        description: 'Information about this disease is not yet in our database.',
        symptoms: 'Please consult with a plant pathologist or agricultural extension service for specific symptom information.',
        treatment: 'Without specific identification, a general recommendation is to remove affected plant parts and improve plant health through proper watering and fertilization.',
        prevention: 'Practice good garden hygiene, crop rotation, and use disease-resistant varieties when available.',
      );
    }
  }
}
