import 'package:flutter/material.dart';

class PredictionSection extends StatefulWidget {
  final String selectedCrop;
  final List<String> crops;
  final String selectedDataset;
  final List<String> datasets;
  final Function(String) onCropChanged;
  final Function(String) onDatasetChanged;

  const PredictionSection({
    super.key,
    required this.selectedCrop,
    required this.crops,
    required this.selectedDataset,
    required this.datasets,
    required this.onCropChanged,
    required this.onDatasetChanged,
  });

  @override
  State<PredictionSection> createState() => _PredictionSectionState();
}

class _PredictionSectionState extends State<PredictionSection> {
  bool _isPredicting = false;
  bool _showResults = false;
  double _predictedYield = 0;
  String _productionTrend = '';

  void _handlePredict() async {
    setState(() {
      _isPredicting = true;
    });

    // Simulate ML prediction delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock prediction results
    final random = (widget.selectedCrop.hashCode % 100) / 100;
    setState(() {
      _predictedYield = 3.8 + random;
      _productionTrend = random > 0.5 ? 'Upward' : 'Stable';
      _isPredicting = false;
      _showResults = true;
    });
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
          value: widget.selectedCrop,
          isExpanded: true,
          underline: Container(
            height: 2,
            color: const Color.fromARGB(255, 0, 77, 64),
          ),
          items: widget.crops.map((crop) {
            return DropdownMenuItem(
              value: crop,
              child: Text(crop),
            );
          }).toList(),
          onChanged: (crop) {
            if (crop != null) widget.onCropChanged(crop);
          },
        ),
        const SizedBox(height: 20),
        // Dataset Selector
        const Text(
          'Select Dataset Source',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: widget.selectedDataset,
          isExpanded: true,
          underline: Container(
            height: 2,
            color: const Color.fromARGB(255, 0, 77, 64),
          ),
          items: widget.datasets.map((dataset) {
            return DropdownMenuItem(
              value: dataset,
              child: Text(dataset),
            );
          }).toList(),
          onChanged: (dataset) {
            if (dataset != null) widget.onDatasetChanged(dataset);
          },
        ),
        const SizedBox(height: 24),
        // Predict Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 77, 64),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isPredicting ? null : _handlePredict,
            child: _isPredicting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Predict Yield',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        // Results Container
        if (_showResults)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color.fromARGB(255, 0, 77, 64).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prediction Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Predicted Yield',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_predictedYield.toStringAsFixed(2)} MT/Ha',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 77, 64),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Production Trend',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _productionTrend == 'Upward'
                                  ? Colors.green[100]
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _productionTrend,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _productionTrend == 'Upward'
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
