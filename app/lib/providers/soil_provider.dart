import 'package:flutter/material.dart';
import '../services/soil_service.dart';

class SoilProvider extends ChangeNotifier {
  final SoilService _soilService = SoilService();

  SoilData? _soilData;
  bool _isLoading = false;
  String? _error;
  double? _latitude;
  double? _longitude;

  SoilData? get soilData => _soilData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSoil(double latitude, double longitude) async {
    try {
      _isLoading = true;
      _error = null;
      _latitude = latitude;
      _longitude = longitude;
      notifyListeners();

      _soilData = await _soilService.fetchSoilData(latitude, longitude);
      _isLoading = false;
    } catch (e) {
      _error = 'Error fetching soil data: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refreshSoil() async {
    if (_latitude != null && _longitude != null) {
      await fetchSoil(_latitude!, _longitude!);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
