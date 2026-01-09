# Quick Reference - What's Ready to Use

## 🌤️ Weather Service
```dart
import 'package:app/services/weather_service.dart';

final weatherService = WeatherService();
final forecast = await weatherService.fetchWeatherForecast(
  23.8103,  // latitude
  90.4125,  // longitude
  location: 'Dhaka'
);

// Access data:
forecast!.dailyForecasts[0].maxTemp
forecast!.dailyForecasts[0].getWeatherIcon()  // "☀️"
```

## 🌍 Soil Service
```dart
import 'package:app/services/soil_service.dart';

final soilService = SoilService();
final soil = await soilService.fetchSoilData(23.8103, 90.4125);

// Use data:
soil!.ph              // 6.5
soil!.getPhInterpretation()  // "Neutral (pH 6.5-7.5)..."
soilService.getSoilRecommendations(soil!)  // List<String>
```

## 🦠 Disease Service
```dart
import 'package:app/services/disease_service.dart';

// Get disease info
final disease = DiseaseDatabase.getDiseaseInfo('rice_blast');
disease!.treatments.forEach(print);  // List of treatment options

// Preprocess image for model
final processed = DiseaseIdentificationService.preprocessImage(image, 224);

// Get all available diseases
DiseaseDatabase.getAllDiseases()  // List<String>
```

## 🌾 Fertilizer Service
```dart
import 'package:app/services/fertilizer_service.dart';

final fertService = FertilizerGuidanceService();

// Get complete plan
final plan = fertService.getFertilizerPlan('rice', 2.0);  // 2 hectares
print(plan['npkValues']['nitrogen']);        // kg needed
print(plan['commonFertilizers']['urea']);    // kg of urea

// Get all crops
fertService.getAvailableCrops()  // 10 crops supported

// Adapted to soil conditions
final adapted = fertService.getAdaptedRecommendations(
  'tomato',
  soilPh: 6.5,
  organicMatter: 2.5
);
```

## 🔄 Crop Rotation Service
```dart
import 'package:app/services/crop_rotation_service.dart';

// Get next recommended crops
final nextCrops = CropRotationService.getRecommendedNextCrops('rice');
// Returns: ['lentil', 'chickpea', 'wheat']

// Multi-year plan
final plan = CropRotationService.generateRotationPlan('rice', 3);
plan.forEach((year) {
  print("Year ${year.year}: ${year.crop} - ${year.reason}");
});

// Check rotation quality
final impact = CropRotationService.getSoilHealthImpact('rice', 'lentil');
print(impact.soilHealthScore);  // 0-100
print(impact.recommendation);   // "Excellent rotation!"
```

## 🤖 RAG Service
```dart
import 'package:app/services/rag_service.dart';

final rag = RAGService();

// Initialize
await rag.initialize(AgriculturalKnowledgeBase.getInitialDocuments());

// Build RAG prompt for Gemini
final prompt = await rag.buildRAGPrompt("How do I grow rice?");

// Or retrieve context directly
final context = await rag.retrieveContext("rice cultivation");
context.relevantDocs.forEach((doc) {
  print("Source: ${doc.source}");
  print("Content: ${doc.content}");
});

// Get stats
print(rag.getStats());  // {total_documents: 5, ...}
```

## 📱 UI Widgets

### Weather & Soil Widget
```dart
import 'package:app/widgets/weather_soil_widget.dart';

WeatherSoilWidget(
  latitude: 23.8103,
  longitude: 90.4125,
  locationName: 'Dhaka',
)
```

### Disease Scanner Screen
```dart
import 'package:app/screens/disease_scanner_screen.dart';

Navigator.push(context, MaterialPageRoute(
  builder: (_) => const DiseaseScannerScreen()
));
```

### Calculator Screen
```dart
import 'package:app/screens/calculator_screen.dart';

Navigator.push(context, MaterialPageRoute(
  builder: (_) => const CalculatorScreen()
));
```

## 🐍 Python Scripts

### Train Disease Model
```bash
cd disease_model_training
pip install -r requirements.txt
python train_disease_model.py
# Outputs: models/disease_model.tflite
```

### Scrape Yearbooks
```bash
python scrape_yearbooks.py --batch yearbook_config.json
# Outputs: scraped_data/*.csv
```

## 🔌 State Management
```dart
import 'package:app/providers/disease_detection_provider.dart';
import 'package:provider/provider.dart';

// Use in widget
context.watch<DiseaseDetectionProvider>();

// Properties:
provider.selectedImagePath
provider.detectedDisease
provider.confidence  // 0.0-1.0
provider.isLoading
provider.errorMessage

// Methods:
provider.setImagePath(path)
provider.setDetectionResult(disease, confidence)
provider.setError(message)
provider.reset()
```

---

## 📋 Crops Supported

### Fertilizer Recommendations (10 crops)
rice, wheat, potato, maize, jute, tomato, lentil, chickpea, onion, brinjal

### Crop Rotation (8 crops)
rice, wheat, lentil, chickpea, maize, potato, tomato, brinjal

### Disease Detection (6 diseases)
rice_blast, rice_brown_spot, wheat_powdery_mildew,
potato_late_blight, tomato_early_blight, brinjal_shoot_and_fruit_borer

---

## 🔑 Configuration

### Default Location (Dhaka)
```
Latitude:  23.8103
Longitude: 90.4125
Name:      Dhaka
```

### API Endpoints (All Free)
- Weather: `https://api.open-meteo.com/v1/forecast`
- Soil: `https://rest.soilgrids.org/soilgrids/v2.0/properties/query`
- Disease: Local TFLite model (on-device)

### Caching
- Weather: 6 hours
- Soil: 30 days
- Disease Images: App cache

---

## 🚨 Important Notes

1. **Disease Model:** Must train before using (see IMPLEMENTATION_GUIDE.md)
2. **Location:** Implement geolocator for dynamic coordinates
3. **RAG:** Expand knowledge base with scraped yearbook data
4. **Testing:** Use Dhaka coordinates (23.8103, 90.4125) for initial tests

---

## 📚 Full Documentation
See `IMPLEMENTATION_GUIDE.md` for step-by-step integration instructions
