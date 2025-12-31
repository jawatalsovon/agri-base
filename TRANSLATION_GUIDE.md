# Comprehensive Translation System Guide

## Overview
The AgriBase app now has a comprehensive translation system that makes it easy to translate all text and database values.

## Key Components

### 1. **translations.dart** - Main Translation Dictionary
Contains all UI strings, crop names, and district names in English and Bengali.

### 2. **translation_helper.dart** - Helper Utilities
Provides extension methods and helper functions for easy translation access.

## How to Use Translations

### Method 1: Using the Helper Extension (Recommended for Simplicity)
```dart
import '../utils/translation_helper.dart';

// In your widget with locale access:
Text('dashboard'.tr(locale))  // Translates the key
```

### Method 2: Using Translations Class Directly
```dart
import '../utils/translations.dart';

Text(Translations.translate(locale, 'dashboard'))
```

### Method 3: Translate Database Values

#### Crop Names (converts "aman_bona" → "Aman Bona" → Bengali translation)
```dart
import '../utils/translation_helper.dart';

String displayName = TranslationHelper.formatCropName('aman_bona', locale);
// Result: "Aman Bona" or "আমান বোনা" (depending on locale)
```

#### District Names
```dart
String displayName = TranslationHelper.formatDistrictName('dhaka', locale);
// Result: "Dhaka" or "ঢাকা"
```

#### Formatted Numbers (with proper English numerals and commas)
```dart
String number = TranslationHelper.formatNumber(1234567.89, decimalPlaces: 2);
// Result: "1234567.89"

String withCommas = TranslationHelper.formatNumberWithCommas(1234567.89, decimalPlaces: 2);
// Result: "1,234,567.89"
```

#### Field Labels
```dart
String label = TranslationHelper.getFieldLabel('production_mt', locale);
// Result: "Production" or "উৎপাদন"
```

## Using in Screens

### For StatelessWidget or Consumer Widgets
```dart
Consumer<LocalizationProvider>(
  builder: (context, localizationProvider, child) {
    final locale = localizationProvider.locale;
    
    return Text(Translations.translate(locale, 'dashboard'));
  },
)
```

### For StatefulWidget
```dart
@override
Widget build(BuildContext context) {
  final localizationProvider = Provider.of<LocalizationProvider>(context);
  final locale = localizationProvider.locale;
  
  return Text(Translations.translate(locale, 'dashboard'));
}
```

## Adding New Translations

### Step 1: Add the key-value pair to translations.dart
```dart
static const Map<String, Map<String, String>> _translations = {
  'en': {
    'newFeature': 'New Feature Name',
    // ...
  },
  'bn': {
    'newFeature': 'নতুন বৈশিষ্ট্য নাম',
    // ...
  },
};
```

### Step 2: Use in your widget
```dart
Text(Translations.translate(locale, 'newFeature'))
```

## Adding New Crop Translations

### Step 1: Add to _cropTranslations in translations.dart
```dart
static const Map<String, Map<String, String>> _cropTranslations = {
  'en': {
    'new_crop_name': 'New Crop Name',
    // ...
  },
  'bn': {
    'new_crop_name': 'নতুন ফসলের নাম',
    // ...
  },
};
```

### Step 2: Use in your widget
```dart
String displayName = TranslationHelper.formatCropName('new_crop_name', locale);
```

## Common Patterns

### Pattern 1: Drop-down with Translated Crop Names
```dart
DropdownButton<String>(
  value: _selectedCrop,
  isExpanded: true,
  items: _crops.map((crop) {
    return DropdownMenuItem(
      value: crop,
      child: Text(TranslationHelper.formatCropName(crop, locale)),
    );
  }).toList(),
  onChanged: (value) { /* ... */ },
)
```

### Pattern 2: Data Display with Translated Labels
```dart
Column(
  children: [
    Text('${TranslationHelper.getFieldLabel('production_mt', locale)}: '
         '${TranslationHelper.formatNumberWithCommas(production, decimalPlaces: 2)}'),
    Text('${TranslationHelper.getFieldLabel('yield_per_hectare', locale)}: '
         '${TranslationHelper.formatNumber(yield_val, decimalPlaces: 2)}'),
  ],
)
```

### Pattern 3: Chart with Translated Title
```dart
SfCartesianChart(
  title: ChartTitle(
    text: Translations.translate(locale, 'cropYieldAnalysis'),
  ),
  // ... rest of chart configuration
)
```

## Key Translation Keys Available

### Navigation
- `home`, `dashboard`, `analytics`, `discover`, `myRegion`, `askAI`

### Data Display
- `selectCrop`, `selectDistrict`, `selectYear`
- `yield`, `area`, `production`, `percentage`
- `historicalData`, `prediction`, `topCrops`, `yieldAnalysis`

### States
- `loading`, `noData`, `error`, `tryAgain`

### Actions
- `cancel`, `yes`, `no`, `ok`, `save`, `delete`, `edit`, `search`

### Dialogs
- `signOut`, `areYouSureSignOut`, `privacyPolicy`, `aboutUs`

## Example: Translating an Entire Screen

### Before (with hardcoded strings)
```dart
class MyScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Text('Select a crop'),
    );
  }
}
```

### After (with translations)
```dart
class MyScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final locale = localizationProvider.locale;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.translate(locale, 'dashboard')),
      ),
      body: Text(Translations.translate(locale, 'selectCrop')),
    );
  }
}
```

## Best Practices

1. **Always use the translation system** - Even if English text looks the same
2. **Use TranslationHelper for database values** - It handles formatting and translation
3. **Numbers should use English numerals** - TranslationHelper.formatNumber ensures this
4. **Extract translation keys to constants** - Use AppStrings class for repeated strings
5. **Provide context in translation keys** - Use descriptive key names like `cropYieldAnalysis` instead of `title`

## Testing Translations

To test that all strings are translated:
1. Switch language in Settings
2. Navigate through all screens
3. Check that all text is in the selected language
4. Verify crop names and numbers display correctly

## Future Enhancements

- Add more crop translations
- Add district translations for all regions
- Add support for plural forms
- Add date/time localization
- Add RTL support for Bengali
