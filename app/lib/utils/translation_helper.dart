import 'package:flutter/material.dart';
import 'translations.dart';

/// Extension on String to easily access translations in widgets
extension TranslationExtension on String {
  /// Translate a key with a given locale
  String tr(Locale locale) => Translations.translate(locale, this);
}

/// Extension on Locale for easy access to language code
extension LocaleExtension on Locale {
  /// Check if current locale is Bengali
  bool get isBengali => languageCode == 'bn';
  
  /// Check if current locale is English
  bool get isEnglish => languageCode == 'en';
}

/// Helper class for formatting and translating database values
class TranslationHelper {
  /// Format crop name from database format (e.g., "Aman_bona" → "Aman bona")
  /// and optionally translate it
  static String formatCropName(String cropName, Locale locale) {
    // Convert underscores to spaces and title case
    final formatted = cropName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
    
    // Try to translate, otherwise return formatted name
    return Translations.translateCrop(locale, cropName) ?? formatted;
  }

  /// Format district name for display
  static String formatDistrictName(String districtName, Locale locale) {
    // Try to translate, otherwise return the name as is
    return Translations.translateDistrict(locale, districtName) ?? districtName;
  }

  /// Convert English numerals to Bengali numerals
  static String _convertToBengaliNumerals(String text) {
    const bengaliNumerals = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = text;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(i.toString(), bengaliNumerals[i]);
    }
    return result;
  }

  /// Format numbers in English numerals (default) or Bengali numerals
  /// Accepts both num and String (for year ranges like "2023-24")
  /// [useBengaliNumerals]: If true, converts numerals to Bengali (०-९), default is false (0-9)
  static String formatNumber(dynamic number, {int? decimalPlaces, bool useBengaliNumerals = false}) {
    String formatted;
    
    if (number is String) {
      formatted = number;
    } else if (number is num) {
      if (decimalPlaces != null) {
        formatted = number.toStringAsFixed(decimalPlaces);
      } else {
        formatted = number.toString();
      }
    } else {
      formatted = number.toString();
    }
    
    if (useBengaliNumerals) {
      formatted = _convertToBengaliNumerals(formatted);
    }
    
    return formatted;
  }

  /// Format large numbers with commas (e.g., 1000000 → 1,000,000)
  /// [locale]: If Bengali, converts to Bengali numerals (০-৯), otherwise English (0-9)
  static String formatNumberWithCommas(num number, {int? decimalPlaces, Locale? locale}) {
    String formattedNumber = decimalPlaces != null 
        ? number.toStringAsFixed(decimalPlaces)
        : number.toString();
    
    final parts = formattedNumber.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    // Add commas to integer part
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String result = integerPart.replaceAll(regex, ',') + decimalPart;
    
    // Convert to Bengali numerals if Bengali locale
    if (locale?.isBengali ?? false) {
      result = _convertToBengaliNumerals(result);
    }
    
    return result;
  }

  /// Get a translated label for common data fields
  static String getFieldLabel(String fieldName, Locale locale) {
    const fieldLabels = {
      'production': 'production',
      'production_mt': 'production',
      'yield': 'yield',
      'yield_per_hectare': 'yield',
      'area': 'area',
      'area_hectares': 'area',
      'year': 'year',
      'district': 'selectDistrict',
      'crop': 'selectCrop',
      'percentage': 'percentage',
    };
    
    final key = fieldLabels[fieldName.toLowerCase()] ?? fieldName;
    return Translations.translate(locale, key);
  }

  /// Translate a generic term
  static String translate(Locale locale, String key) {
    return Translations.translate(locale, key);
  }
}

/// Common UI strings that are repeated across the app
class AppStrings {
  static const String welcomeToAgriBase = 'welcomeToAgriBase';
  static const String helloUser = 'helloUser';
  static const String signInForEnhancedFeatures = 'signInForEnhancedFeatures';
  static const String bangladeshiAgriculture = 'bangladeshiAgriculture';
  static const String ourMission = 'ourMission';
  static const String whatAgribaseOffers = 'whatAgribaseOffers';
  static const String smartAnalytics = 'smartAnalytics';
  static const String regionalInsights = 'regionalInsights';
  static const String sustainablePractices = 'sustainablePractices';
  static const String marketIntelligence = 'marketIntelligence';
  static const String getInTouch = 'getInTouch';
  static const String emailSupport = 'emailSupport';
  static const String phoneSupport = 'phoneSupport';
  static const String signOut = 'signOut';
  static const String areYouSureSignOut = 'areYouSureSignOut';
  static const String cancel = 'cancel';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String ok = 'ok';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String save = 'save';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String sort = 'sort';
  static const String clear = 'clear';
  static const String reset = 'reset';
  static const String apply = 'apply';
  static const String close = 'close';
  static const String back = 'back';
  static const String next = 'next';
  static const String previous = 'previous';
  static const String finish = 'finish';
  static const String year = 'year';
  static const String month = 'month';
  static const String day = 'day';
  static const String percentage = 'percentage';
}
