import 'package:flutter/material.dart';
import '../../services/crops_database_service.dart';
import '../../utils/data_utils.dart';

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
      print('Error loading crops: $e');
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
      print('Error loading prediction data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop Selector
        const Text(
          'Select Crop for Prediction',
          style: TextStyle(
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
            return DropdownMenuItem(
              value: crop,
              child: Text(crop.toTitleCase()),
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
            highlightColor: Colors.white.withOpacity(0.1),
            splashColor: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color.fromARGB(255, 0, 77, 64).withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Tooltip(
                      message: 'Predicted total production for 2025',
                      child: Text(
                        'Predicted Total Production (2025)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Tooltip(
                      message: 'Predicted total production in metric tons',
                      child: Text(
                        '${(_totalYield['total_production'] as num? ?? 0).toStringAsFixed(2)} MT',
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
                            'Predicted Avg Yield: ${(_totalYield['average_yield'] as num? ?? 0).toStringAsFixed(2)} MT/Ha',
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
          const Text(
            'Top Predicted Yield Districts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            highlightColor: Colors.white.withOpacity(0.1),
            splashColor: Colors.white.withOpacity(0.2),
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
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'District',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Predicted Yield (MT/Ha)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Predicted Production (MT)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Table Rows
                    if (_topDistricts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No prediction data available'),
                      )
                    else
                      ..._topDistricts.map((district) {
                        final yieldValue =
                            (district['yield_per_hectare'] as num? ?? 0)
                                .toDouble();
                        final production =
                            (district['production_mt_pred'] as num? ?? 0)
                                .toDouble();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Tooltip(
                                  message: 'District name',
                                  child: Text(
                                    district['district'] as String? ?? '',
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
                                    yieldValue.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Tooltip(
                                  message: 'Predicted total production',
                                  child: Text(
                                    production.toStringAsFixed(2),
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
  }
}
