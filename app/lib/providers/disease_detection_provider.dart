import 'package:flutter/material.dart';

class DiseaseDetectionProvider extends ChangeNotifier {
  String? _selectedImagePath;
  String? _detectedDisease;
  double _confidence = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedImagePath => _selectedImagePath;
  String? get detectedDisease => _detectedDisease;
  double get confidence => _confidence;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setImagePath(String path) {
    _selectedImagePath = path;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDetectionResult(String disease, double conf) {
    _detectedDisease = disease;
    _confidence = conf;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _detectedDisease = null;
    notifyListeners();
  }

  void reset() {
    _selectedImagePath = null;
    _detectedDisease = null;
    _confidence = 0.0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
