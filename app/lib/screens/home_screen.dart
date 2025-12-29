import 'package:flutter/material.dart';
import '../services/mock_crop_data.dart';
import '../widgets/sections/historical_data_section.dart';
import '../widgets/sections/prediction_section.dart';
import '../widgets/interactive_bangladesh_map.dart';

class AgriBaseHomeScreen extends StatefulWidget {
  const AgriBaseHomeScreen({super.key});

  @override
  State<AgriBaseHomeScreen> createState() => _AgriBaseHomeScreenState();
}

class _AgriBaseHomeScreenState extends State<AgriBaseHomeScreen> {
  int _selectedNavIndex = 1; // "Insights" is selected
  int _selectedSectionIndex = 0; // 0: Historical, 1: Prediction
  String _selectedCrop = 'Rice';
  String _selectedDataset = 'Previous Dataset';
  String? _selectedCropForMap;

  final List<String> _crops = ['Rice', 'Wheat', 'Jute'];
  final List<String> _datasets = ['Previous Dataset', 'Generated Dataset'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 77, 64), // Dark Forest Green
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'AgriBase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Section Tabs
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSectionIndex = 0;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Historical Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedSectionIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                color: _selectedSectionIndex == 0
                                    ? const Color.fromARGB(255, 0, 77, 64)
                                    : Colors.grey,
                              ),
                            ),
                            if (_selectedSectionIndex == 0)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 3,
                                color: const Color.fromARGB(255, 0, 77, 64),
                              ),
                            if (_selectedSectionIndex != 0)
                              const SizedBox(height: 11),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSectionIndex = 1;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Prediction (AI/ML)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedSectionIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                color: _selectedSectionIndex == 1
                                    ? const Color.fromARGB(255, 0, 77, 64)
                                    : Colors.grey,
                              ),
                            ),
                            if (_selectedSectionIndex == 1)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 3,
                                color: const Color.fromARGB(255, 0, 77, 64),
                              ),
                            if (_selectedSectionIndex != 1)
                              const SizedBox(height: 11),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Content based on selected section
            if (_selectedSectionIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HistoricalDataSection(
                  selectedCrop: _selectedCrop,
                  crops: _crops,
                  onCropChanged: (crop) {
                    setState(() {
                      _selectedCrop = crop;
                    });
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PredictionSection(
                  selectedCrop: _selectedCrop,
                  crops: _crops,
                  selectedDataset: _selectedDataset,
                  datasets: _datasets,
                  onCropChanged: (crop) {
                    setState(() {
                      _selectedCrop = crop;
                    });
                  },
                  onDatasetChanged: (dataset) {
                    setState(() {
                      _selectedDataset = dataset;
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),
            // Interactive Map Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'District Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Crop Selector for Map
                  DropdownButton<String>(
                    value: _selectedCropForMap ?? _crops[0],
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
                      setState(() {
                        _selectedCropForMap = crop;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Interactive Map
                  InteractiveBangladeshMap(
                    selectedCrop: _selectedCropForMap ?? _crops[0],
                    districtDataMap: MockCropData.cropDataByDistrict,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 0, 77, 64),
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Ask AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 0, 77, 64),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'My Region',
          ),
        ],
      ),
    );
  }
}
