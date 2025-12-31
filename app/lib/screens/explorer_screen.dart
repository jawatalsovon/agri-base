import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/crops_database_service.dart';
import '../models/district_data.dart';
import '../widgets/interactive_bangladesh_map.dart';
import '../providers/localization_provider.dart';
import '../utils/translations.dart';
import '../utils/translation_helper.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final CropsDatabaseService _cropsService = CropsDatabaseService();

  List<String> _crops = [];
  List<String> _years = [];
  String? _selectedCrop;
  String? _selectedYear;

  Map<String, DistrictData> _districtDataMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final crops = await _cropsService.getAllCrops();
      if (crops.isNotEmpty) {
        setState(() {
          _crops = crops;
          _selectedCrop = crops.first;
        });
        await _loadYearsForCrop(crops.first);
      }
    } catch (e) {
      // ignore: empty_catches
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadYearsForCrop(String crop) async {
    if (crop.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final years = await _cropsService.getYearsForCrop(crop);
      if (years.isNotEmpty) {
        setState(() {
          _years = years;
          _selectedYear = years.first;
        });
        await _loadMapData();
      }
    } catch (e) {
      // ignore: empty_catches
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMapData() async {
    if (_selectedCrop == null || _selectedYear == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final districtData = await _cropsService.getDistrictDataForMap(
        _selectedCrop!,
        _selectedYear!,
      );

      // Convert to DistrictData format for the map
      final districtDataMap = <String, DistrictData>{};
      for (final entry in districtData.entries) {
        final district = entry.key;
        final data = entry.value;

        districtDataMap[district] = DistrictData(
          name: district,
          bnName: district, // TODO: Add Bengali name mapping
          lat: 23.8103, // TODO: Add actual coordinates
          long: 90.4125,
          production: (data['production'] as num? ?? 0).toDouble(),
          yieldValue: (data['yield'] as num? ?? 0).toDouble(),
          percentage: (data['percentage'] as num? ?? 0).toDouble(),
        );
      }

      setState(() {
        _districtDataMap = districtDataMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale;
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 77, 64),
            elevation: 0,
            title: Text(
              Translations.translate(locale, 'discover'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Selector
                Text(
                  Translations.translate(locale, 'selectCrop'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedCrop,
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: const Color.fromARGB(255, 0, 77, 64),
                  ),
                  items: _crops.map((crop) {
                    final translatedCrop = TranslationHelper.formatCropName(crop, locale);
                    return DropdownMenuItem(value: crop, child: Text(translatedCrop));
                  }).toList(),
                  onChanged: (crop) {
                    if (crop != null) {
                      setState(() {
                        _selectedCrop = crop;
                        _selectedYear = null;
                        _years = [];
                      });
                      _loadYearsForCrop(crop);
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Year Selector
                Text(
                  Translations.translate(locale, 'selectYear'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedYear,
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: const Color.fromARGB(255, 0, 77, 64),
                  ),
                  items: _years.map((year) {
                    final displayYear = TranslationHelper.formatNumber(year, useBengaliNumerals: locale.languageCode == 'bn');
                    return DropdownMenuItem(value: year, child: Text(displayYear));
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setState(() {
                        _selectedYear = year;
                      });
                      _loadMapData();
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Info Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select a districts to see yield and percentage contribution',
                          style: TextStyle(fontSize: 12, color: Colors.green[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Map
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_selectedCrop != null && _selectedYear != null)
                  InteractiveBangladeshMap(
                    selectedCrop: _selectedCrop!,
                    districtDataMap: {_selectedCrop!: _districtDataMap},
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
