import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/crops_database_service.dart';
import '../../providers/localization_provider.dart';
import '../../utils/translations.dart';
import '../../utils/translation_helper.dart';

class PredictionSection extends StatefulWidget {
  const PredictionSection({super.key});

  @override
  State<PredictionSection> createState() => _PredictionSectionState();
}

class _PredictionSectionState extends State<PredictionSection> {
  final CropsDatabaseService _cropsService = CropsDatabaseService();

  List<String> _crops = [];
  String? _selectedCrop;

  List<Map<String, dynamic>> _topDistricts = [];
  Map<String, dynamic> _totalYield = {};
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
        await _loadData();
      }
    } catch (e) {
      // ignore: empty_catches
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_selectedCrop == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final topDistricts = await _cropsService
          .getTopYieldDistrictsFromPredictions(_selectedCrop!);
      final totalYield = await _cropsService.getTotalYieldFromPredictions(
        _selectedCrop!,
      );

      setState(() {
        _topDistricts = topDistricts;
        _totalYield = totalYield;
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
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Selector
            Text(
              locale.languageCode == 'bn' ? 'পূর্বাভাসের জন্য ফসল নির্বাচন করুন' : 'Select Crop for Prediction',
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
                return DropdownMenuItem(
                  value: crop,
                  child: Text(translatedCrop),
                );
              }).toList(),
              onChanged: (crop) {
                if (crop != null) {
                  setState(() {
                    _selectedCrop = crop;
                  });
                  _loadData();
                }
              },
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_selectedCrop != null) ...[
              // Total Yield Card
              InkWell(
                onTap: () {},
                highlightColor: Colors.white.withValues(alpha: 0.1),
                splashColor: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color.fromARGB(
                    255,
                    0,
                    77,
                    64,
                  ).withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: 'Predicted total production for 2025',
                          child: Text(
                            locale.languageCode == 'bn' 
                              ? 'পূর্বাভাসিত মোট উৎপাদন (2025)'
                              : 'Predicted Total Production (2025)',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Tooltip(
                          message: 'Predicted total production in metric tons',
                          child: Text(
                            '${TranslationHelper.formatNumberWithCommas((_totalYield['total_production'] as num? ?? 0).toDouble(), decimalPlaces: 3, locale: locale)} ${Translations.translate(locale, 'mt')}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 77, 64),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Predicted average yield per hectare',
                              child: Text(
                                '${Translations.translate(locale, 'yield')}: ${TranslationHelper.formatNumberWithCommas((_totalYield['average_yield'] as num? ?? 0).toDouble(), decimalPlaces: 3, locale: locale)} ${Translations.translate(locale, 'mtPerHectare')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Top Yield Districts
              Text(
                locale.languageCode == 'bn' ? 'শীর্ষ পূর্বাভাসিত ফলন জেলা' : 'Top Predicted Yield Districts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                highlightColor: Colors.white.withValues(alpha: 0.1),
                splashColor: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              0,
                              77,
                              64,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  Translations.translate(locale, 'district'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  locale.languageCode == 'bn' 
                                    ? 'পূর্বাভাসিত ফলন (MT/Ha)'
                                    : 'Predicted Yield (MT/Ha)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  locale.languageCode == 'bn'
                                    ? 'পূর্বাভাসিত উৎপাদন (MT)'
                                    : 'Predicted Production (MT)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Table Rows
                        if (_topDistricts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              locale.languageCode == 'bn' 
                                ? 'কোনো পূর্বাভাস ডেটা পাওয়া যায়নি'
                                : 'No prediction data available',
                            ),
                          )
                        else
                          ..._topDistricts.map((district) {
                            final yieldValue =
                                (district['yield_per_hectare'] as num? ?? 0)
                                    .toDouble();
                            final production =
                                (district['production_mt_pred'] as num? ?? 0)
                                    .toDouble();
                            final districtName = district['district'] as String? ?? '';
                            final translatedDistrict = TranslationHelper.formatDistrictName(districtName, locale);
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Tooltip(
                                      message: 'District name',
                                      child: Text(
                                        translatedDistrict,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Tooltip(
                                      message: 'Predicted yield per hectare',
                                      child: Text(
                                        TranslationHelper.formatNumberWithCommas(yieldValue, locale: locale),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Tooltip(
                                      message: 'Predicted total production',
                                      child: Text(
                                        TranslationHelper.formatNumberWithCommas(production, decimalPlaces: 3, locale: locale),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
