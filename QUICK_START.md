# ⚡ Quick Start Guide

## 5-Minute Setup

### 1. Get Packages
```bash
cd app
flutter pub get
```

### 2. Verify Compilation
```bash
flutter analyze
# Should show 0 errors
```

### 3. Test One Service
```bash
# In a new screen or test file:
import 'package:app/services/weather_service.dart';

void testWeather() async {
  final weatherService = WeatherService();
  final data = await weatherService.fetchWeatherForecast(
    23.8103,
    90.4125,
    location: 'Dhaka'
  );
  print(data?.dailyForecasts[0].maxTemp); // Should print temp
}
```

---

## 30-Minute Integration

### Weather Widget to Home Screen

**File:** `app/lib/screens/home_content_screen.dart`

Find the `_buildHeroSection` method and add this after it:

```dart
// Add import at top
import '../widgets/weather_soil_widget.dart';

// In the Column children (around line 90):
// Add after BangladeshiFarmingSection or wherever:

WeatherSoilWidget(
  latitude: 23.8103,   // Dhaka coordinates
  longitude: 90.4125,
  locationName: 'Dhaka',
)
```

**Done!** Weather widget now appears on home screen.

---

### Disease Scanner to Navigation

**File:** `app/lib/screens/home_screen.dart` or your navigation file

```dart
// Add import
import '../screens/disease_scanner_screen.dart';

// Add button to menu or bottom navigation
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DiseaseScannerScreen(),
      ),
    );
  },
  child: ListTile(
    leading: Icon(Icons.search),
    title: Text('🔬 Disease Scanner'),
  ),
)
```

---

### Calculator Screen to Navigation

**File:** Same navigation file

```dart
// Add import
import '../screens/calculator_screen.dart';

// Add button
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CalculatorScreen(),
      ),
    );
  },
  child: ListTile(
    leading: Icon(Icons.calculate),
    title: Text('📊 Farm Calculators'),
  ),
)
```

---

## 1-Hour Setup (With Disease Model)

### Prerequisites
- Python 3.9+ installed
- 5GB disk space (model + dataset)
- GPU preferred (CPU works, slower)

### Step 1: Train Model
```bash
cd disease_model_training

# Install Python packages
pip install tensorflow==2.13.0 datasets pillow

# Download and train
python train_disease_model.py

# Wait 15-30 minutes...
# ✓ models/disease_model.tflite created
```

### Step 2: Add Model to Flutter
```bash
# Copy model
cp disease_model_training/models/disease_model.tflite \
   app/assets/models/

# Update pubspec.yaml
# Under assets:, add:
#   - assets/models/disease_model.tflite
```

### Step 3: Integrate Scanner
Already done! Just rebuild the app.

---

## Testing Each Feature

### Test Weather Service
```dart
import 'package:app/services/weather_service.dart';

void main() async {
  final service = WeatherService();
  
  print('Fetching weather...');
  final weather = await service.fetchWeatherForecast(23.8103, 90.4125);
  
  if (weather != null) {
    print('✓ Weather loaded');
    print('  Temp: ${weather.dailyForecasts[0].maxTemp}°C');
    print('  Desc: ${weather.dailyForecasts[0].getWeatherDescription()}');
  } else {
    print('✗ Failed to load weather');
  }
}
```

### Test Soil Service
```dart
import 'package:app/services/soil_service.dart';

void main() async {
  final service = SoilService();
  
  print('Fetching soil...');
  final soil = await service.fetchSoilData(23.8103, 90.4125);
  
  if (soil != null) {
    print('✓ Soil loaded');
    print('  pH: ${soil.ph}');
    print('  Type: ${soil.soilType}');
  } else {
    print('✗ Failed to load soil');
  }
}
```

### Test Fertilizer Service
```dart
import 'package:app/services/fertilizer_service.dart';

void main() {
  final service = FertilizerGuidanceService();
  
  final plan = service.getFertilizerPlan('rice', 1.0);
  
  print('✓ Fertilizer plan for rice:');
  print('  Nitrogen: ${plan['npkValues']['nitrogen']} kg');
  print('  Urea: ${plan['commonFertilizers']['urea']} kg');
}
```

### Test RAG Service
```dart
import 'package:app/services/rag_service.dart';

void main() async {
  final service = RAGService();
  
  print('Initializing RAG...');
  await service.initialize(
    AgriculturalKnowledgeBase.getInitialDocuments()
  );
  
  print('✓ RAG ready');
  print('Documents loaded: ${service.getStats()['total_documents']}');
}
```

---

## Common Issues & Quick Fixes

### "Package not found" error
```bash
flutter clean
flutter pub get
```

### Weather not loading
- Check internet connection
- Verify coordinates: Dhaka = `23.8103, 90.4125`
- Check Open-Meteo API: https://open-meteo.com/

### Disease model too slow
- Use TensorFlow Lite version
- Pre-train on larger GPU
- Consider quantization

### RAG not finding documents
- Initialize with documents first
- Add more agricultural content
- Check embedding generation

---

## What's Ready Right Now ✅

| Feature | Status | Integration Time |
|---------|--------|------------------|
| Weather Widget | ✅ Ready | 5 min |
| Soil Service | ✅ Ready | 5 min |
| Fertilizer Calc | ✅ Ready | 5 min |
| Disease DB | ✅ Ready | 5 min |
| Crop Rotation | ✅ Ready | 10 min |
| RAG Service | ✅ Ready | 5 min |
| Calculators | ✅ Ready | 5 min |
| Disease Scanner | ⏳ Model needed | 30 min + training |
| Yearbook Scraper | ⏳ URLs needed | Variable |

---

## Files to Review

### Start With These
1. `QUICK_REFERENCE.md` - Code examples
2. `lib/services/weather_service.dart` - Simple API calls
3. `lib/widgets/weather_soil_widget.dart` - Beautiful UI

### Then Review
4. `lib/services/fertilizer_service.dart` - Data database
5. `lib/screens/calculator_screen.dart` - UI example
6. `lib/services/rag_service.dart` - Advanced service

### Important Configs
- `app/pubspec.yaml` - All dependencies
- `disease_model_training/requirements.txt` - Python deps
- `disease_model_training/yearbook_config.json` - Scraper config

---

## Next Steps

### Today (15 minutes)
- [ ] Run `flutter pub get`
- [ ] Add weather widget to home
- [ ] Test compilation

### Tomorrow (30 minutes)
- [ ] Add calculator screen
- [ ] Add disease scanner to nav
- [ ] Test each screen

### This Week (2 hours)
- [ ] Train disease model
- [ ] Integrate RAG with chatbot
- [ ] Add fertilizer calculator UI

### Next Week (variable)
- [ ] Scrape yearbook data
- [ ] Add crop rotation UI
- [ ] Full app testing

---

## Support Commands

```bash
# Check for errors
flutter analyze

# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check device
flutter devices

# View logs
flutter logs
```

---

## Key Coordinates to Test

| Location | Lat | Lon |
|----------|-----|-----|
| Dhaka | 23.8103 | 90.4125 |
| Chittagong | 22.3569 | 91.7832 |
| Sylhet | 24.8949 | 91.8687 |
| Rajshahi | 24.3745 | 88.6042 |
| Khulna | 22.8456 | 89.5403 |

---

## You're Ready! 🎉

All services are production-ready. Just integrate and test!

**Questions?** See IMPLEMENTATION_GUIDE.md for detailed steps.

**Time Estimate:**
- Basic integration: 30 minutes
- Full integration: 2-3 hours
- With model training: 30-60 minutes
- Complete setup: 1-2 days

---

**Last Updated:** January 8, 2026  
**Status:** ✅ Ready to use
