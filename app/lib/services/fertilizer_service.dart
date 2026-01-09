// Fertilizer Guidance Database
// Based on BARC (Bangladesh Agricultural Research Council) recommendations

class FertilizerRecommendation {
  final String cropName;
  final String cropNameBn;
  final double nitrogenPerHectare; // kg/ha
  final double phosphorusPerHectare; // kg/ha
  final double potassiumPerHectare; // kg/ha
  final String organicFertilizerRecommendation;
  final String notes;
  final String soilType;
  final List<String> commonFertilizers;

  FertilizerRecommendation({
    required this.cropName,
    required this.cropNameBn,
    required this.nitrogenPerHectare,
    required this.phosphorusPerHectare,
    required this.potassiumPerHectare,
    required this.organicFertilizerRecommendation,
    required this.notes,
    required this.soilType,
    required this.commonFertilizers,
  });
}

class FertilizerGuidanceService {
  static final FertilizerGuidanceService _instance =
      FertilizerGuidanceService._internal();

  factory FertilizerGuidanceService() {
    return _instance;
  }

  FertilizerGuidanceService._internal();

  final Map<String, FertilizerRecommendation> _recommendations = {
    'rice': FertilizerRecommendation(
      cropName: 'Rice',
      cropNameBn: 'ধান',
      nitrogenPerHectare: 110,
      phosphorusPerHectare: 25,
      potassiumPerHectare: 40,
      organicFertilizerRecommendation: '5-10 tons of compost',
      notes:
          'Apply N in 3 splits: 1/3 at land prep, 1/3 at tillering, 1/3 at panicle initiation. For high-yielding varieties, increase N to 140 kg/ha.',
      soilType: 'Alluvial, Clay Loam',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP/SOP (50% K2O)',
        'Cow dung',
        'Poultry manure',
      ],
    ),
    'wheat': FertilizerRecommendation(
      cropName: 'Wheat',
      cropNameBn: 'গম',
      nitrogenPerHectare: 120,
      phosphorusPerHectare: 60,
      potassiumPerHectare: 40,
      organicFertilizerRecommendation: '5 tons of compost',
      notes:
          'Apply N in 2 splits: 50% at sowing, 50% at tillering (40 DAS). Phosphorus and K should be applied at sowing.',
      soilType: 'Clay Loam, Silt Loam',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'DAP (18:46:0)',
      ],
    ),
    'potato': FertilizerRecommendation(
      cropName: 'Potato',
      cropNameBn: 'আলু',
      nitrogenPerHectare: 150,
      phosphorusPerHectare: 100,
      potassiumPerHectare: 120,
      organicFertilizerRecommendation: '15-20 tons of compost',
      notes:
          'Potato is a heavy feeder. Apply all P and K at planting. Apply N in 2 splits: 50% at planting, 50% at 30 DAS. High K helps in tuber quality.',
      soilType: 'Sandy Loam, Loam',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'Farm yard manure',
      ],
    ),
    'maize': FertilizerRecommendation(
      cropName: 'Maize',
      cropNameBn: 'ভুট্টা',
      nitrogenPerHectare: 150,
      phosphorusPerHectare: 70,
      potassiumPerHectare: 60,
      organicFertilizerRecommendation: '5 tons of compost',
      notes:
          'Apply N in 3 splits. First dose (1/3) at sowing, second (1/3) at 4-6 leaves stage, third (1/3) at 8-10 leaves stage. P and K at sowing.',
      soilType: 'Well-drained loamy soils',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'Cow dung',
      ],
    ),
    'jute': FertilizerRecommendation(
      cropName: 'Jute',
      cropNameBn: 'পাট',
      nitrogenPerHectare: 80,
      phosphorusPerHectare: 40,
      potassiumPerHectare: 30,
      organicFertilizerRecommendation: '3-5 tons of compost',
      notes:
          'Jute requires moderate nutrients. N should be applied in 2 splits: at sowing and at thinning. Use well-rotted manure.',
      soilType: 'Clay Loam, Silty Loam',
      commonFertilizers: ['Urea (46% N)', 'TSP (46% P2O5)', 'Cow dung'],
    ),
    'tomato': FertilizerRecommendation(
      cropName: 'Tomato',
      cropNameBn: 'টমেটো',
      nitrogenPerHectare: 120,
      phosphorusPerHectare: 80,
      potassiumPerHectare: 100,
      organicFertilizerRecommendation: '10-15 tons of compost',
      notes:
          'Apply N in 3-4 splits. First dose at planting, then every 3 weeks. High K improves fruit quality. Excess N causes vegetative growth.',
      soilType: 'Well-drained loamy soil',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'Compost',
      ],
    ),
    'lentil': FertilizerRecommendation(
      cropName: 'Lentil',
      cropNameBn: 'মসুর',
      nitrogenPerHectare: 20,
      phosphorusPerHectare: 60,
      potassiumPerHectare: 30,
      organicFertilizerRecommendation: '2-3 tons of compost',
      notes:
          'Legume - fixes atmospheric N. Requires low N. High P promotes nodule formation. Good for soil recovery after cereals.',
      soilType: 'Well-drained loam',
      commonFertilizers: ['TSP (46% P2O5)', 'Compost', 'Vermicompost'],
    ),
    'chickpea': FertilizerRecommendation(
      cropName: 'Chickpea',
      cropNameBn: 'ছোলা',
      nitrogenPerHectare: 15,
      phosphorusPerHectare: 70,
      potassiumPerHectare: 35,
      organicFertilizerRecommendation: '2-3 tons of compost',
      notes:
          'Legume crop. Minimal N requirement due to N fixation. Requires good P for nodule development. Helps improve soil fertility.',
      soilType: 'Well-drained clay loam',
      commonFertilizers: ['TSP (46% P2O5)', 'Compost', 'Farm yard manure'],
    ),
    'onion': FertilizerRecommendation(
      cropName: 'Onion',
      cropNameBn: 'পেঁয়াজ',
      nitrogenPerHectare: 120,
      phosphorusPerHectare: 60,
      potassiumPerHectare: 90,
      organicFertilizerRecommendation: '8-10 tons of compost',
      notes:
          'Apply all P and K at planting. Apply N in 4 splits during growing season. Bulb quality depends on good nutrition.',
      soilType: 'Well-drained sandy loam',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'Cow dung',
      ],
    ),
    'brinjal': FertilizerRecommendation(
      cropName: 'Brinjal (Eggplant)',
      cropNameBn: 'বেগুন',
      nitrogenPerHectare: 150,
      phosphorusPerHectare: 80,
      potassiumPerHectare: 120,
      organicFertilizerRecommendation: '10-15 tons of compost',
      notes:
          'Heavy feeder. Apply N in 4-5 splits. First dose 30 days after planting. Maintain balanced nutrition for continuous fruiting.',
      soilType: 'Well-drained loamy soil',
      commonFertilizers: [
        'Urea (46% N)',
        'TSP (46% P2O5)',
        'MOP (50% K2O)',
        'Compost',
      ],
    ),
  };

  /// Get fertilizer recommendation for a crop
  FertilizerRecommendation? getRecommendation(String cropName) {
    return _recommendations[cropName.toLowerCase()];
  }

  /// Get all available crops
  List<String> getAvailableCrops() {
    return _recommendations.keys.toList();
  }

  /// Calculate fertilizer needed for given area
  Map<String, double> calculateFertilizerForArea(
    String cropName,
    double areaInHectares,
  ) {
    final rec = getRecommendation(cropName);
    if (rec == null) return {};

    return {
      'nitrogen': rec.nitrogenPerHectare * areaInHectares,
      'phosphorus': rec.phosphorusPerHectare * areaInHectares,
      'potassium': rec.potassiumPerHectare * areaInHectares,
    };
  }

  /// Calculate amount of urea needed (common N source)
  /// Urea contains 46% N
  double calculateUreaNeeded(double nitrogenRequired) {
    return nitrogenRequired / 0.46;
  }

  /// Calculate amount of TSP needed (common P source)
  /// TSP (Triple Super Phosphate) contains 46% P2O5
  double calculateTSPNeeded(double phosphorusRequired) {
    return phosphorusRequired / 0.46;
  }

  /// Calculate amount of MOP needed (common K source)
  /// MOP (Muriate of Potash) contains 60% K2O
  double calculateMOPNeeded(double potassiumRequired) {
    return potassiumRequired / 0.60;
  }

  /// Get detailed fertilizer plan for a crop and area
  Map<String, dynamic> getFertilizerPlan(
    String cropName,
    double areaInHectares,
  ) {
    final rec = getRecommendation(cropName);
    if (rec == null) return {};

    final npk = calculateFertilizerForArea(cropName, areaInHectares);

    return {
      'cropName': rec.cropName,
      'cropNameBn': rec.cropNameBn,
      'area': areaInHectares,
      'npkValues': {
        'nitrogen': npk['nitrogen']?.toStringAsFixed(2),
        'phosphorus': npk['phosphorus']?.toStringAsFixed(2),
        'potassium': npk['potassium']?.toStringAsFixed(2),
      },
      'commonFertilizers': {
        'urea': calculateUreaNeeded(npk['nitrogen'] ?? 0).toStringAsFixed(2),
        'tsp': calculateTSPNeeded(npk['phosphorus'] ?? 0).toStringAsFixed(2),
        'mop': calculateMOPNeeded(npk['potassium'] ?? 0).toStringAsFixed(2),
      },
      'organicRecommendation': rec.organicFertilizerRecommendation,
      'notes': rec.notes,
      'soilType': rec.soilType,
    };
  }

  /// Get recommendations based on soil conditions
  List<String> getAdaptedRecommendations(
    String cropName,
    double soilPh,
    double organicMatter,
  ) {
    final recommendations = <String>[];
    final rec = getRecommendation(cropName);

    if (rec == null) {
      return ['No recommendations found for this crop'];
    }

    // pH-based adjustments
    if (soilPh < 6.0) {
      recommendations.add(
        'Apply lime before planting. Acidic soil may reduce nutrient availability.',
      );
      recommendations.add('Increase P fertilizer by 20% for acidic soils');
    } else if (soilPh > 8.0) {
      recommendations.add(
        'In alkaline soil, ${rec.cropName} may face micronutrient deficiency.',
      );
      recommendations.add(
        'Consider adding chelated micronutrients (Zn, Mn, B)',
      );
    }

    // Organic matter based adjustments
    if (organicMatter < 2.0) {
      recommendations.add(
        'Low organic matter - Add extra compost (1-2 tons/ha)',
      );
      recommendations.add('Apply 50% extra N through organic sources');
    } else if (organicMatter > 5.0) {
      recommendations.add(
        'High organic matter - Reduce commercial N by 20-30%',
      );
    }

    return recommendations;
  }
}
