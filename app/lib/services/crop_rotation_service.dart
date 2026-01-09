class CropRotationService {
  // Crop characteristics
  static final Map<String, CropInfo> cropDatabase = {
    'rice': CropInfo(
      name: 'Rice',
      nameBn: 'ধান',
      season: 'Kharif/Rabi',
      soilDepletion: 'High',
      nitrogen: -5, // Legumes improve N, so rice after legume is better
      phosphorus: 20,
      potassium: 30,
      nitrogenFixing: false,
      pests: ['Rice Blast', 'Brown Spot', 'Stem Borer'],
    ),
    'wheat': CropInfo(
      name: 'Wheat',
      nameBn: 'গম',
      season: 'Rabi',
      soilDepletion: 'High',
      nitrogen: 30,
      phosphorus: 25,
      potassium: 20,
      nitrogenFixing: false,
      pests: ['Powdery Mildew', 'Rust', 'Armyworm'],
    ),
    'lentil': CropInfo(
      name: 'Lentil',
      nameBn: 'মসুর',
      season: 'Rabi',
      soilDepletion: 'Low',
      nitrogen: -20, // Adds nitrogen
      phosphorus: 10,
      potassium: 5,
      nitrogenFixing: true,
      pests: ['Aphids', 'Bruchid'],
    ),
    'chickpea': CropInfo(
      name: 'Chickpea',
      nameBn: 'ছোলা',
      season: 'Rabi',
      soilDepletion: 'Low',
      nitrogen: -20, // Adds nitrogen
      phosphorus: 12,
      potassium: 8,
      nitrogenFixing: true,
      pests: ['Aphids', 'Pod Borer'],
    ),
    'maize': CropInfo(
      name: 'Maize',
      nameBn: 'ভুট্টা',
      season: 'Kharif/Summer',
      soilDepletion: 'High',
      nitrogen: 35,
      phosphorus: 22,
      potassium: 25,
      nitrogenFixing: false,
      pests: ['Stem Borer', 'Armyworm', 'Cob Borer'],
    ),
    'potato': CropInfo(
      name: 'Potato',
      nameBn: 'আলু',
      season: 'Rabi',
      soilDepletion: 'Very High',
      nitrogen: 40,
      phosphorus: 30,
      potassium: 50,
      nitrogenFixing: false,
      pests: ['Late Blight', 'Aphids', 'Cutworm'],
    ),
    'tomato': CropInfo(
      name: 'Tomato',
      nameBn: 'টমেটো',
      season: 'Kharif/Rabi',
      soilDepletion: 'High',
      nitrogen: 35,
      phosphorus: 25,
      potassium: 40,
      nitrogenFixing: false,
      pests: ['Early Blight', 'Whitefly', 'Fruit Borer'],
    ),
    'brinjal': CropInfo(
      name: 'Brinjal',
      nameBn: 'বেগুন',
      season: 'Kharif/Summer',
      soilDepletion: 'High',
      nitrogen: 35,
      phosphorus: 25,
      potassium: 40,
      nitrogenFixing: false,
      pests: ['Fruit Borer', 'Leaf Spot', 'Shoot Borer'],
    ),
    'mung_bean': CropInfo(
      name: 'Mung Bean',
      nameBn: 'মুগ ডাল',
      season: 'Kharif/Summer',
      soilDepletion: 'Low',
      nitrogen: -25, // Fixes atmospheric nitrogen
      phosphorus: 8,
      potassium: 4,
      nitrogenFixing: true,
      pests: ['Bean Beetle', 'Thrips'],
    ),
    'peas': CropInfo(
      name: 'Peas',
      nameBn: 'মটর',
      season: 'Rabi',
      soilDepletion: 'Low',
      nitrogen: -20, // Fixes nitrogen
      phosphorus: 10,
      potassium: 6,
      nitrogenFixing: true,
      pests: ['Aphids', 'Powdery Mildew'],
    ),
    'beans': CropInfo(
      name: 'Beans',
      nameBn: 'সিম',
      season: 'Kharif/Rabi',
      soilDepletion: 'Low',
      nitrogen: -22, // Fixes nitrogen
      phosphorus: 9,
      potassium: 5,
      nitrogenFixing: true,
      pests: ['Bean Beetle', 'Pod Borer'],
    ),
  };

  static const Map<String, List<String>> rotationRules = {
    'rice': [
      'mung_bean',
      'lentil',
      'wheat',
    ], // Legumes after rice to restore nitrogen
    'wheat': [
      'rice',
      'maize',
      'chickpea',
    ], // Nitrogen-fixing legumes restore soil after wheat
    'lentil': [
      'rice',
      'wheat',
      'maize',
    ], // Legume restores N, then followed by heavy feeders
    'chickpea': ['rice', 'wheat', 'maize'], // Similar to lentil rotation
    'maize': [
      'lentil',
      'chickpea',
      'wheat',
    ], // Heavy feeder needs legume to restore nitrogen
    'potato': [
      'peas',
      'beans',
      'wheat',
    ], // Pest cycle interruption and nutrient balancing
    'tomato': [
      'beans',
      'wheat',
      'peas',
    ], // Nutrient balancing and pest reduction
    'brinjal': [
      'beans',
      'peas',
      'wheat',
    ], // Similar pattern to other vegetables
  };

  // Rotation rationale based on CSV data
  static const Map<String, String> rotationRationale = {
    'rice_to_mung_bean':
        'Nitrogen Fixation - Mung bean restores soil nitrogen after rice',
    'rice_to_lentil':
        'Soil Organic Carbon - Lentil improves soil structure and organic matter',
    'rice_to_wheat':
        'Pest Cycle Interruption - Breaks rice pest cycle with different crop',
    'wheat_to_rice':
        'Soil Organic Carbon - Rice-wheat rotation maintains fertility',
    'wheat_to_chickpea':
        'Nitrogen Credits - Chickpea fixes atmospheric nitrogen for next crop',
    'wheat_to_maize':
        'Yield Stabilization - Diversifies crops for consistent production',
    'lentil_to_rice':
        'Pulse-Cereal Mix - Traditional rotation for dryland productivity',
    'lentil_to_wheat':
        'Protein Optimization - Legume-cereal mix for nutrient balance',
    'chickpea_to_rice':
        'Pulse-Cereal Mix - Nitrogen fixed by chickpea benefits rice',
    'chickpea_to_wheat':
        'Protein Optimization - Legume-cereal combination for soil health',
    'maize_to_lentil':
        'Nitrogen Fixation - Legume restores nitrogen depleted by maize',
    'maize_to_chickpea':
        'Nitrogen Fixation - Nitrogen-fixing legume after nitrogen-hungry maize',
    'potato_to_peas':
        'Pest Cycle Interruption - Different crop family breaks pest cycle',
    'potato_to_beans':
        'Disease Prevention - Legume rotation reduces potato diseases',
    'tomato_to_beans':
        'Pathogen Reduction - Legume rotation breaks tomato pathogen cycle',
    'tomato_to_wheat':
        'Root Depth Diversity - Different root depths utilize soil nutrients',
    'brinjal_to_beans':
        'Fruit Borer Control - Legume breaks brinjal pest cycle',
    'brinjal_to_peas':
        'Disease Prevention - Different crop family prevents brinjal diseases',
  };

  /// Get recommended crops after a specific crop
  static List<String> getRecommendedNextCrops(String currentCrop) {
    return rotationRules[currentCrop.toLowerCase()] ?? [];
  }

  /// Get crop information
  static CropInfo? getCropInfo(String cropName) {
    return cropDatabase[cropName.toLowerCase()];
  }

  /// Generate multi-year rotation plan
  static List<RotationPlan> generateRotationPlan(
    String startingCrop,
    int yearsPlanned,
  ) {
    final plan = <RotationPlan>[];
    String currentCrop = startingCrop.toLowerCase();

    for (int year = 1; year <= yearsPlanned; year++) {
      final cropInfo = getCropInfo(currentCrop);
      if (cropInfo == null) break;

      plan.add(
        RotationPlan(
          year: year,
          crop: currentCrop,
          cropInfo: cropInfo,
          reason: _getRotationReason(currentCrop),
        ),
      );

      // Move to next crop
      final nextCrops = getRecommendedNextCrops(currentCrop);
      if (nextCrops.isNotEmpty) {
        currentCrop = nextCrops[0]; // Simple: pick first recommended
      }
    }

    return plan;
  }

  /// Get reason for rotation based on crop characteristics
  static String _getRotationReason(String crop) {
    final cropInfo = getCropInfo(crop);
    if (cropInfo == null) return '';

    if (cropInfo.nitrogenFixing) {
      return 'Legume crop - Adds nitrogen to soil through biological fixation';
    } else if (cropInfo.nitrogen > 30) {
      return 'Heavy feeder - Benefits from nitrogen fixed by previous legume crop';
    } else if (cropInfo.soilDepletion == 'Very High') {
      return 'High demand crop - Requires well-prepared soil with added nutrients';
    } else {
      return 'Balanced nutrient requirement - Moderate feeder crop';
    }
  }

  /// Get transition-specific rationale from rotation combinations
  static String getTransitionRationale(String previousCrop, String nextCrop) {
    final key = '${previousCrop.toLowerCase()}_to_${nextCrop.toLowerCase()}';
    return rotationRationale[key] ?? _getRotationReason(nextCrop);
  }

  /// Get soil health impact
  static SoilHealthImpact getSoilHealthImpact(
    String previousCrop,
    String nextCrop,
  ) {
    final prevInfo = getCropInfo(previousCrop);
    final nextInfo = getCropInfo(nextCrop);

    if (prevInfo == null || nextInfo == null) {
      return SoilHealthImpact(
        isGoodRotation: false,
        soilNitrogenImpact: 0,
        soilHealthScore: 0,
        recommendation: 'Crop information not found',
      );
    }

    // Check if it's a good rotation
    final recommendedNext = getRecommendedNextCrops(previousCrop);
    final isGood = recommendedNext.contains(nextCrop.toLowerCase());

    // Calculate nitrogen impact
    final nitrogenImpact = prevInfo.nitrogen + nextInfo.nitrogen;

    // Calculate health score (0-100)
    int healthScore = 50;
    if (isGood) healthScore += 30;
    if (prevInfo.nitrogenFixing) healthScore += 15;
    if (nextInfo.pests.isEmpty ||
        (prevInfo.pests.isEmpty ||
            !_haveSamePests(prevInfo.pests, nextInfo.pests))) {
      healthScore += 10;
    }

    healthScore = healthScore.clamp(0, 100);

    String recommendation = '';
    if (isGood) {
      recommendation =
          'Excellent rotation! ${prevInfo.name} to ${nextInfo.name} improves soil health.';
    } else {
      recommendation = 'Consider rotating with: ${recommendedNext.join(", ")}';
    }

    return SoilHealthImpact(
      isGoodRotation: isGood,
      soilNitrogenImpact: nitrogenImpact,
      soilHealthScore: healthScore,
      recommendation: recommendation,
    );
  }

  static bool _haveSamePests(List<String> pests1, List<String> pests2) {
    return pests1.any((pest) => pests2.contains(pest));
  }

  /// Get all available crops
  static List<String> getAllCrops() {
    return cropDatabase.keys.toList();
  }
}

class CropInfo {
  final String name;
  final String nameBn;
  final String season;
  final String soilDepletion;
  final double nitrogen; // kg/ha depleted
  final double phosphorus;
  final double potassium;
  final bool nitrogenFixing;
  final List<String> pests;

  CropInfo({
    required this.name,
    required this.nameBn,
    required this.season,
    required this.soilDepletion,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.nitrogenFixing,
    required this.pests,
  });
}

class RotationPlan {
  final int year;
  final String crop;
  final CropInfo cropInfo;
  final String reason;

  RotationPlan({
    required this.year,
    required this.crop,
    required this.cropInfo,
    required this.reason,
  });
}

class SoilHealthImpact {
  final bool isGoodRotation;
  final double soilNitrogenImpact;
  final int soilHealthScore; // 0-100
  final String recommendation;

  SoilHealthImpact({
    required this.isGoodRotation,
    required this.soilNitrogenImpact,
    required this.soilHealthScore,
    required this.recommendation,
  });
}
