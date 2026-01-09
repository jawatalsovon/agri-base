# AgriBase Implementation Guide

## 🎯 Overview

This guide covers the implementation of all new features for the AgriBase app:

1. ✅ **Weather & Climate Integration** - 7-day forecast + historical data
2. ✅ **Soil Data Integration** - SoilGrids API integration
3. ✅ **Disease Detection** - ML model for crop disease identification
4. ✅ **Fertilizer Guidance** - BARC-based recommendations
5. ✅ **Calculator Screens** - Fertilizer, seed, yield planning
6. ✅ **Crop Rotation Planning** - Rotation recommendations
7. ✅ **RAG for Chatbot** - Enhanced AI with knowledge base
8. ✅ **Data Scraping** - Yearbook PDF extraction

---

## 📋 Feature Details & Implementation Status

### 1. Weather & Climate Data ✅

**Status:** Ready for integration

**Files Created:**
- `lib/services/weather_service.dart` - Weather API client
- `lib/widgets/weather_soil_widget.dart` - UI widget

**Integration Steps:**

a) Update `lib/screens/home_content_screen.dart` to include the weather widget:

```dart
import '../widgets/weather_soil_widget.dart';

// In the Home build method, add:
WeatherSoilWidget(
  latitude: 23.8103,  // Dhaka
  longitude: 90.4125,
  locationName: 'Dhaka',
)
```

b) For dynamic location, add to location-based screens:

```dart
// Get user's current location
import 'package:geolocator/geolocator.dart';

final position = await Geolocator.getCurrentPosition();
WeatherSoilWidget(
  latitude: position.latitude,
  longitude: position.longitude,
  locationName: 'Current Location',
)
```

**API Used:** Open-Meteo (Free, no API key required)
- Forecast endpoint: `https://api.open-meteo.com/v1/forecast`
- Archive endpoint: `https://api.open-meteo.com/v1/archive`

---

### 2. Soil Data Integration ✅

**Status:** Ready for integration

**Files Created:**
- `lib/services/soil_service.dart` - SoilGrids API client

**Integration Steps:**

Add to home screen or My Region screen:

```dart
final soilService = SoilService();
final soilData = await soilService.fetchSoilData(
  latitude: 23.8103,
  longitude: 90.4125,
);

// Display recommendations
final recommendations = soilService.getSoilRecommendations(soilData!);
```

**API Used:** SoilGrids REST API
- Endpoint: `https://rest.soilgrids.org/soilgrids/v2.0/properties/query`
- Returns: pH, Organic Carbon, Clay%, Sand%, Silt%

---

### 3. Disease Detection System ✅

**Status:** Model training required

**Files Created:**
- `lib/services/disease_service.dart` - Disease database & service
- `lib/screens/disease_scanner_screen.dart` - UI for disease detection
- `lib/providers/disease_detection_provider.dart` - State management
- `disease_model_training/train_disease_model.py` - Model training script

**Integration Steps:**

#### Step 1: Train the Disease Model

```bash
cd disease_model_training

# Install dependencies
pip install -r requirements.txt

# Train model
python train_disease_model.py
```

This will create:
- `models/disease_model.tflite` - Mobile-optimized model
- `models/disease_model_info.json` - Model metadata

#### Step 2: Add Model to Flutter App

1. Copy `disease_model.tflite` to `app/assets/models/`
2. Update `pubspec.yaml`:

```yaml
assets:
  - assets/models/disease_model.tflite
```

#### Step 3: Update Disease Service

In `disease_service.dart`, replace mock inference with TFLite:

```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class DiseaseIdentificationService {
  static Interpreter? _interpreter;
  
  static Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/disease_model.tflite');
  }
  
  static Future<Map<String, dynamic>> identify(String imagePath) async {
    // Implementation using _interpreter
  }
}
```

#### Step 4: Add to Navigation

In `lib/main.dart` or navigation provider:

```dart
// Add to app navigation
// Example: In bottom navigation or drawer

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DiseaseScannerScreen(),
  ),
);
```

---

### 4. Fertilizer Guidance Database ✅

**Status:** Ready to use

**Files Created:**
- `lib/services/fertilizer_service.dart` - BARC recommendations

**Usage Example:**

```dart
final fertilizerService = FertilizerGuidanceService();

// Get recommendation for a crop
final plan = fertilizerService.getFertilizerPlan('rice', 1.0); // 1 hectare

// Calculate for different area
final npk = fertilizerService.calculateFertilizerForArea('wheat', 2.0);

// Get soil-adjusted recommendations
final adapted = fertilizerService.getAdaptedRecommendations(
  'tomato',
  soilPh: 6.5,
  organicMatter: 2.5,
);
```

**Crops Supported:**
- Rice, Wheat, Maize, Potato
- Lentil, Chickpea
- Tomato, Brinjal, Onion
- Jute

---

### 5. Farm Calculator Screens ✅

**Status:** Ready for integration

**Files Created:**
- `lib/screens/calculator_screen.dart` - 3-tab calculator UI

**Integration Steps:**

Add to navigation:

```dart
// In home screen or navigation menu
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CalculatorScreen(),
  ),
);
```

**Features:**
1. **Fertilizer Calculator** - Based on BARC recommendations
2. **Seed Calculator** - Calculates seed needed per area
3. **Yield Calculator** - Estimates production based on yield rates

---

### 6. Crop Rotation Planning ✅

**Status:** Ready for integration

**Files Created:**
- `lib/services/crop_rotation_service.dart` - Rotation engine

**Usage Example:**

```dart
import '../services/crop_rotation_service.dart';

// Get recommended next crops
final nextCrops = CropRotationService.getRecommendedNextCrops('rice');
// Returns: ['lentil', 'chickpea', 'wheat']

// Generate multi-year plan
final plan = CropRotationService.generateRotationPlan('rice', 3); // 3 years

// Check rotation quality
final impact = CropRotationService.getSoilHealthImpact('rice', 'lentil');
print(impact.isGoodRotation); // true
print(impact.soilHealthScore); // 80
```

**To Add to UI:**

Create a new rotation planning screen:

```dart
class CropRotationScreen extends StatefulWidget {
  // Display rotation recommendations
  // Show soil health impact
  // Multi-year planning tools
}
```

---

### 7. RAG-Enhanced Chatbot ✅

**Status:** Ready for integration with Gemini

**Files Created:**
- `lib/services/rag_service.dart` - Retrieval-Augmented Generation

**Integration with Existing Chatbot:**

In `lib/screens/assistant_screen.dart` (or where chatbot is):

```dart
import '../services/rag_service.dart';

final ragService = RAGService();

// Initialize with agricultural knowledge
await ragService.initialize(
  AgriculturalKnowledgeBase.getInitialDocuments(),
);

// Before sending to Gemini:
final ragPrompt = await ragService.buildRAGPrompt(userQuestion);

// Send enhanced prompt to Gemini API
final response = await geminiClient.sendMessage(ragPrompt);
```

**RAG Benefits:**
- Faster responses (context from knowledge base first)
- More accurate agricultural advice
- Grounded in agricultural sources
- Can be customized with scraped yearbook data

---

### 8. Data Scraping from Yearbooks ✅

**Status:** Scripts ready, requires manual URL input

**Files Created:**
- `disease_model_training/scrape_yearbooks.py` - PDF scraper
- `disease_model_training/yearbook_config.json` - Configuration

**Implementation Steps:**

#### Step 1: Gather PDF URLs

Get all yearbook URLs from: https://bbs.portal.gov.bd/

Update `yearbook_config.json` with actual URLs

#### Step 2: Run Scraper

```bash
cd disease_model_training

# Single PDF
python scrape_yearbooks.py --url "https://..." --output crops_2017.csv

# Batch process
python scrape_yearbooks.py --batch yearbook_config.json
```

#### Step 3: Import to SQLite

```python
import pandas as pd
import sqlite3

# Load CSV
df = pd.read_csv('scraped_data/agri_yearbook_2017_table_1.csv')

# Import to database
conn = sqlite3.connect('app/assets/databases/crops.db')
df.to_sql('crop_production', conn, if_exists='append', index=False)
```

---

## 🔧 Setup & Installation

### Prerequisites

- Flutter 3.10+
- Python 3.9+
- TensorFlow 2.12+

### Flutter Packages Installation

Already updated in `pubspec.yaml`:

```bash
cd app
flutter pub get
```

### Python Dependencies

```bash
cd disease_model_training
pip install -r requirements.txt
```

---

## 📱 UI Integration Checklist

- [ ] Add WeatherSoilWidget to Home screen
- [ ] Add DiseaseScannerScreen to navigation
- [ ] Add CalculatorScreen to navigation
- [ ] Create CropRotationScreen UI
- [ ] Update Assistant screen to use RAG service
- [ ] Update My Region screen with Soil data
- [ ] Add location picker for weather/soil

---

## 🔑 API Keys Required

| API | Key Required | Free Tier | Notes |
|-----|--|--|--|
| Open-Meteo | ❌ No | Yes | Weather & historical data |
| SoilGrids | ❌ No | Yes | Soil properties (250m resolution) |
| Gemini | ✅ Yes | Limited | AI chatbot (already configured) |

---

## 📊 Database Schema Updates

Add new tables for crop rotations and disease history:

```sql
CREATE TABLE crop_rotations (
  id INTEGER PRIMARY KEY,
  farmer_id TEXT,
  field_id TEXT,
  year INTEGER,
  crop TEXT,
  area_hectares REAL,
  notes TEXT
);

CREATE TABLE disease_detections (
  id INTEGER PRIMARY KEY,
  farmer_id TEXT,
  crop TEXT,
  disease TEXT,
  confidence REAL,
  date DATETIME,
  image_path TEXT,
  recommendation TEXT
);

CREATE TABLE soil_tests (
  id INTEGER PRIMARY KEY,
  farmer_id TEXT,
  latitude REAL,
  longitude REAL,
  ph REAL,
  organic_matter REAL,
  date DATETIME
);
```

---

## 🚀 Next Steps

### Immediate (Week 1)
1. Train disease detection model
2. Integrate weather widget to home
3. Add calculator screens

### Short-term (Week 2-3)
1. Add disease scanner to navigation
2. Implement crop rotation UI
3. Integrate RAG with chatbot

### Medium-term (Week 4+)
1. Scrape yearbook data
2. Import historical data to database
3. Add user account cloud sync
4. Implement prediction model improvements

---

## 🐛 Troubleshooting

### Weather Widget Not Loading
- Check internet connection
- Verify Open-Meteo endpoint is accessible
- Check GPS/location permissions

### Disease Model Not Working
- Ensure TFLite model is in assets/
- Check model input size matches preprocessing (224x224)
- Verify image permissions on Android/iOS

### Soil Data Unavailable
- SoilGrids API might be temporarily paused
- Check coordinates are valid
- Use cache for offline access

### RAG Not Working
- Initialize documents before use
- Check knowledge base format
- Verify embeddings are generated

---

## 📚 References

- [Open-Meteo API](https://open-meteo.com/)
- [SoilGrids](https://soilgrids.org/)
- [BD Crop-Vegetable Plant Disease Dataset](https://huggingface.co/datasets/Saon110/bd-crop-vegetable-plant-disease-dataset)
- [BARC Fertilizer Recommendations](https://barc.gov.bd/)
- [Bangladesh Statistical Yearbooks](https://bbs.portal.gov.bd/)

---

## 📞 Support

For issues with:
- **Weather/Soil APIs**: Check endpoint documentation
- **Disease Model**: Re-train with Saon110 dataset
- **Fertilizer Data**: Consult BARC publications
- **RAG Service**: Expand knowledge base with scraped data

---

**Last Updated:** January 2026
**Version:** 1.0
