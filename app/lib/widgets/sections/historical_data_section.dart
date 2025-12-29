import 'package:flutter/material.dart';
import '../../models/year_statistics.dart';
import '../../services/mock_crop_data.dart';

class HistoricalDataSection extends StatelessWidget {
  final String selectedCrop;
  final List<String> crops;
  final Function(String) onCropChanged;

  const HistoricalDataSection({
    super.key,
    required this.selectedCrop,
    required this.crops,
    required this.onCropChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yearStats = MockCropData.getYearStatistics(selectedCrop);
    final totalProduction = MockCropData.getTotalProduction(selectedCrop);
    final avgYield = MockCropData.getAverageYield(selectedCrop);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop Selector
        DropdownButton<String>(
          value: selectedCrop,
          isExpanded: true,
          underline: Container(
            height: 2,
            color: const Color.fromARGB(255, 0, 77, 64),
          ),
          items: crops.map((crop) {
            return DropdownMenuItem(
              value: crop,
              child: Text(crop),
            );
          }).toList(),
          onChanged: (crop) {
            if (crop != null) onCropChanged(crop);
          },
        ),
        const SizedBox(height: 20),
        // Total Production Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Production (2023)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(totalProduction / 1000000).toStringAsFixed(2)}M MT',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+3.8% vs 2022',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Average Yield Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Yield (2023)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${avgYield.toStringAsFixed(2)} MT/Ha',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+5.6% vs 2022',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Year-over-Year Statistics Table
        const Text(
          'Year-over-Year Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
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
                      Expanded(child: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('Production (MT)',
                              style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      Expanded(
                          child: Text('Yield (MT/Ha)',
                              style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Table Rows
                ...yearStats.map((stat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            stat.year.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${(stat.production / 1000000).toStringAsFixed(2)}M',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            stat.yield.toStringAsFixed(2),
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
    );
  }
}
