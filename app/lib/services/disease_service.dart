import 'package:image/image.dart' as img;
import 'dart:typed_data';

class DiseaseInfo {
  final String diseaseName;
  final String diseaseNameBn;
  final String cropAffected;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> prevention;
  final double confidenceScore; // 0-1
  final String severity; // Low, Medium, High

  DiseaseInfo({
    required this.diseaseName,
    required this.diseaseNameBn,
    required this.cropAffected,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.prevention,
    required this.confidenceScore,
    required this.severity,
  });
}

class DiseaseDatabase {
  static final Map<String, DiseaseInfo> diseases = {
    'rice_blast': DiseaseInfo(
      diseaseName: 'Rice Blast',
      diseaseNameBn: 'ধানের ব্লাস্ট',
      cropAffected: 'Rice',
      description:
          'Fungal disease caused by Magnaporthe oryzae. Affects leaves, stems, and grains.',
      symptoms: [
        'Gray-white lesions on leaves with dark borders',
        'Diamond-shaped spots on stem',
        'Grain discoloration before harvest',
        'Premature plant death in severe cases',
      ],
      treatments: [
        'Spray Mancozeb 75% WP @ 2.5 g/liter water',
        'Use Tricyclazole 75% WP @ 1.5 g/liter water',
        'Apply Propiconazole at recommended dose',
        'Repeat spraying at 10-15 day intervals',
      ],
      prevention: [
        'Use disease-resistant varieties',
        'Proper field sanitation - remove infected debris',
        'Avoid excessive nitrogen fertilizer',
        'Maintain proper water level in field',
        'Apply bio-fungicide (Trichoderma) before planting',
      ],
      confidenceScore: 0.0,
      severity: 'High',
    ),
    'rice_brown_spot': DiseaseInfo(
      diseaseName: 'Brown Spot',
      diseaseNameBn: 'ধানের বাদামী দাগ',
      cropAffected: 'Rice',
      description:
          'Fungal disease caused by Bipolaris oryzae. Often appears during grain filling.',
      symptoms: [
        'Circular brown lesions on leaves',
        'Red-brown spots on grain',
        'Lesions have concentric rings',
        'Severe damage to grain quality',
      ],
      treatments: [
        'Spray Carbendazim 50% WP @ 1 g/liter water',
        'Use Hexaconazole 5% EC @ 1.5 ml/liter water',
        'Apply Copper fungicides for severe infection',
        'Spray at 15-day intervals',
      ],
      prevention: [
        'Use treated and certified seeds',
        'Proper field sanitation',
        'Improve plant nutrition, especially potassium',
        'Avoid waterlogging',
        'Spray Bordeaux mixture (1%) during monsoon',
      ],
      confidenceScore: 0.0,
      severity: 'Medium',
    ),
    'wheat_powdery_mildew': DiseaseInfo(
      diseaseName: 'Powdery Mildew',
      diseaseNameBn: 'গমের পাউডারি মিলডিউ',
      cropAffected: 'Wheat',
      description:
          'Fungal disease caused by Blumeria graminis. White powdery coating on leaves.',
      symptoms: [
        'White powdery coating on leaf surface',
        'Starts on lower leaves and moves upward',
        'Affected leaves become yellow and necrotic',
        'Stunted plant growth',
      ],
      treatments: [
        'Spray Sulfur powder @ 5-6 kg/hectare',
        'Use Carbendazim 50% WP @ 1 g/liter water',
        'Apply Hexaconazole 5% EC @ 1.5 ml/liter water',
        'Spray at 10-day intervals',
      ],
      prevention: [
        'Use resistant varieties',
        'Ensure proper spacing for good air circulation',
        'Avoid excess nitrogen fertilization',
        'Spray before disease appears in endemic areas',
      ],
      confidenceScore: 0.0,
      severity: 'Medium',
    ),
    'potato_late_blight': DiseaseInfo(
      diseaseName: 'Late Blight',
      diseaseNameBn: 'আলুর দেরি ব্লাইট',
      cropAffected: 'Potato',
      description:
          'Water mold disease. Highly destructive in cool, moist conditions.',
      symptoms: [
        'Water-soaked lesions on leaves, often at leaf margins',
        'White mold on leaf undersides',
        'Rapid leaf death and plant collapse',
        'Tuber rot with brown discoloration',
      ],
      treatments: [
        'Spray Mancozeb 75% WP @ 2.5 g/liter water',
        'Use Metalaxyl + Mancozeb @ recommended dose',
        'Apply Chlorothalonil 75% WP @ 2 g/liter water',
        'Spray every 7-10 days in moist weather',
      ],
      prevention: [
        'Use disease-free seed potatoes',
        'Destroy infected plants immediately',
        'Improve field drainage',
        'Avoid overhead irrigation',
        'Destroy haulms after harvest',
        'Proper crop rotation (2-3 years)',
      ],
      confidenceScore: 0.0,
      severity: 'High',
    ),
    'tomato_early_blight': DiseaseInfo(
      diseaseName: 'Early Blight',
      diseaseNameBn: 'টমেটোর আর্লি ব্লাইট',
      cropAffected: 'Tomato',
      description:
          'Fungal disease caused by Alternaria. Affects leaves and stems.',
      symptoms: [
        'Concentric rings on affected leaves (target spots)',
        'Yellow halo around spots',
        'Affects lower leaves first',
        'Stem cankers',
      ],
      treatments: [
        'Remove infected leaves and destroy',
        'Spray Mancozeb 75% WP @ 2.5 g/liter water',
        'Use Chlorothalonil 75% WP @ 2 g/liter water',
        'Apply Copper fungicides',
        'Spray at 10-15 day intervals',
      ],
      prevention: [
        'Avoid overhead irrigation',
        'Stake and prune plants for ventilation',
        'Remove lower leaves as plant grows',
        'Proper field sanitation',
        'Apply mulch to prevent soil splash',
        'Crop rotation with non-solanaceous crops',
      ],
      confidenceScore: 0.0,
      severity: 'Medium',
    ),
    'brinjal_shoot_and_fruit_borer': DiseaseInfo(
      diseaseName: 'Shoot and Fruit Borer',
      diseaseNameBn: 'বেগুনের শুট এবং ফ্রুট বোরার',
      cropAffected: 'Brinjal',
      description:
          'Insect pest - Leucinodes orbonalis. Larvae bore into shoots and fruits.',
      symptoms: [
        'Entry holes in shoots and fruits',
        'Wilting of terminal shoots',
        'Hollow fruits with insect droppings inside',
        'Deformed and unmarketable fruits',
      ],
      treatments: [
        'Spray Spinosad 45% SC @ 0.5 ml/liter water',
        'Use Cypermethrin 10% EC @ 1 ml/liter water',
        'Apply Carbaryl 50% WP @ 2 g/liter water',
        'Spray at 7-10 day intervals',
        'Install pheromone traps',
      ],
      prevention: [
        'Use net/nylon screen over nursery',
        'Handpick affected shoots and fruits',
        'Field sanitation - remove crop debris',
        'Intercropping with repellent plants',
        'Use resistant varieties if available',
        'Proper weed management',
      ],
      confidenceScore: 0.0,
      severity: 'High',
    ),
  };

  static DiseaseInfo? getDiseaseInfo(String diseaseKey) {
    return diseases[diseaseKey.toLowerCase()];
  }

  static List<String> getAllDiseases() {
    return diseases.keys.toList();
  }
}

class DiseaseIdentificationService {
  /// Preprocess image for model input
  static Uint8List preprocessImage(img.Image image, int targetSize) {
    // Resize image to target size (224x224 or 256x256 depending on model)
    final resized = img.copyResize(
      image,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to float32 and normalize to [0, 1]
    final List<double> flattenedPixels = [];

    for (var pixel in resized) {
      flattenedPixels.add(pixel.r.toDouble() / 255.0);
      flattenedPixels.add(pixel.g.toDouble() / 255.0);
      flattenedPixels.add(pixel.b.toDouble() / 255.0);
    }

    // Convert to bytes (float32)
    final buffer = Float32List(flattenedPixels.length);
    for (int i = 0; i < flattenedPixels.length; i++) {
      buffer[i] = flattenedPixels[i];
    }

    return buffer.buffer.asUint8List();
  }

  /// Get disease recommendations
  static List<String> getDiseaseRecommendations(String diseaseKey) {
    final disease = DiseaseDatabase.getDiseaseInfo(diseaseKey);
    if (disease == null) return [];

    final recommendations = <String>[];
    recommendations.add('🔴 Disease: ${disease.diseaseName}');
    recommendations.add('\n📋 Symptoms:');
    for (var symptom in disease.symptoms) {
      recommendations.add('  • $symptom');
    }
    recommendations.add('\n💊 Treatment:');
    for (var treatment in disease.treatments) {
      recommendations.add('  • $treatment');
    }
    recommendations.add('\n🛡️ Prevention:');
    for (var prevention in disease.prevention) {
      recommendations.add('  • $prevention');
    }

    return recommendations;
  }

  /// Simple mock identification (for testing without model)
  /// Returns the disease key (will be replaced by model inference)
  static String identifyDisease(String imagePath, double confidence) {
    // In production, this would use TFLite model to classify the disease
    // For now, return a varied sample disease key based on image path hash
    // TODO: Integrate actual TFLite model
    final diseases = [
      'rice_blast',
      'rice_brown_spot',
      'wheat_powdery_mildew',
      'potato_late_blight',
      'tomato_early_blight',
      'brinjal_shoot_and_fruit_borer',
    ];
    final hash = imagePath.hashCode.abs();
    return diseases[hash % diseases.length];
  }
}
