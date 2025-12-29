import 'package:flutter/material.dart';
import '../services/crops_database_service.dart';
import '../services/database_service.dart';

class MyRegionScreen extends StatefulWidget {
  const MyRegionScreen({super.key});

  @override
  State<MyRegionScreen> createState() => _MyRegionScreenState();
}

class _MyRegionScreenState extends State<MyRegionScreen> {
  final CropsDatabaseService _cropsService = CropsDatabaseService();
  
  List<String> _districts = [];
  List<String> _years = [];
  String? _selectedDistrict;
  String? _selectedYear;
  
  List<Map<String, dynamic>> _topCrops = [];
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
      final districts = await _cropsService.getAllDistricts();
      if (districts.isNotEmpty) {
        setState(() {
          _districts = districts;
          _selectedDistrict = districts.first;
        });
        await _loadYearsForDistrict(districts.first);
      }
    } catch (e) {
      print('Error loading districts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadYearsForDistrict(String district) async {
    if (district.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get years from crop_data for this district
      final query = '''
        SELECT DISTINCT year 
        FROM crop_data 
        WHERE district = ? 
        ORDER BY year DESC
      ''';
      final results = await DatabaseService.instance.queryCrops(query, [district]);
      final years = results.map((row) => row['year'] as String).toList();
      
      if (years.isNotEmpty) {
        setState(() {
          _years = years;
          _selectedYear = years.first;
        });
        await _loadData();
      }
    } catch (e) {
      print('Error loading years: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_selectedDistrict == null || _selectedYear == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final topCrops = await _cropsService.getTopCropsForDistrict(_selectedDistrict!, _selectedYear!);
      setState(() {
        _topCrops = topCrops;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading top crops: $e');
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
          'My Region',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    _selectedYear = null;
                    _years = [];
                  });
                  _loadYearsForDistrict(district);
                }
              },
            ),
            const SizedBox(height: 20),
            // Year Selector
            const Text(
              'Select Year',
              style: TextStyle(
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
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null) {
                  setState(() {
                    _selectedYear = year;
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
            else if (_topCrops.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No data available for selected region and year'),
                ),
              )
            else ...[
              Text(
                'Top 10 Most Yielding Crops in $_selectedDistrict ($_selectedYear)',
                style: const TextStyle(
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
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 77, 64).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 1, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('Crop', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Production (MT)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                            Expanded(flex: 2, child: Text('Yield (MT/Ha)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Table Rows
                      ..._topCrops.asMap().entries.map((entry) {
                        final index = entry.key;
                        final crop = entry.value;
                        final production = (crop['production_mt'] as num? ?? 0).toDouble();
                        final yieldValue = (crop['yield_per_hectare'] as num? ?? 0).toDouble();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: index < 3 
                                        ? Colors.amber.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: index < 3 ? Colors.amber[900] : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  crop['crop_name'] as String? ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  production.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  yieldValue.toStringAsFixed(2),
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

