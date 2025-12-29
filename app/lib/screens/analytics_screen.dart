import 'package:flutter/material.dart';
import '../services/crops_database_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final CropsDatabaseService _cropsService = CropsDatabaseService();
  
  List<String> _crops = [];
  List<String> _districts = [];
  String? _selectedCrop;
  String? _selectedDistrict;
  
  List<Map<String, dynamic>> _yieldByYears = [];
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
      final districts = await _cropsService.getAllDistricts();
      
      setState(() {
        _crops = crops;
        _districts = districts;
        if (crops.isNotEmpty) _selectedCrop = crops.first;
        if (districts.isNotEmpty) _selectedDistrict = districts.first;
      });
      
      if (_selectedCrop != null && _selectedDistrict != null) {
        await _loadData();
      }
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_selectedCrop == null || _selectedDistrict == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final yieldData = await _cropsService.getYieldByYears(_selectedCrop!, _selectedDistrict!);
      setState(() {
        _yieldByYears = yieldData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading yield data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 77, 64),
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Selector
            const Text(
              'Select Crop',
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
                  child: Text(crop),
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
            // District Selector
            const Text(
              'Select Region/District',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedDistrict,
              isExpanded: true,
              underline: Container(
                height: 2,
                color: const Color.fromARGB(255, 0, 77, 64),
              ),
              items: _districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (district) {
                if (district != null) {
                  setState(() {
                    _selectedDistrict = district;
                  });
                  _loadData();
                }
              },
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_yieldByYears.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No data available for selected crop and district'),
                ),
              )
            else ...[
              const Text(
                'Total Yield by Years',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(title: const AxisTitle(text: 'Production (MT)')),
                    series: <CartesianSeries>[
                      LineSeries<Map<String, dynamic>, String>(
                        dataSource: _yieldByYears,
                        xValueMapper: (data, _) => data['year'] as String? ?? '',
                        yValueMapper: (data, _) => (data['production_mt'] as num? ?? 0).toDouble(),
                        name: 'Production',
                        color: const Color.fromARGB(255, 0, 77, 64),
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Data Table
              const Text(
                'Year-over-Year Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 77, 64).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(child: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text('Production (MT)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                            Expanded(child: Text('Yield (MT/Ha)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._yieldByYears.map((data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['year'] as String? ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (data['production_mt'] as num? ?? 0).toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (data['yield_per_hectare'] as num? ?? 0).toStringAsFixed(2),
                                  textAlign: TextAlign.right,
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
            ],
          ],
        ),
      ),
    );
  }
}

