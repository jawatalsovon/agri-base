import 'package:flutter/material.dart';
import '../services/fertilizer_service.dart';

class CalculatorScreen extends StatefulWidget {
  final String mode; // 'fertilizer' or 'seed'
  const CalculatorScreen({super.key, this.mode = 'fertilizer'});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late FertilizerGuidanceService _fertilizerService;

  // Fertilizer Calculator State
  String selectedCrop = 'rice';
  double areaInHectares = 1.0;
  Map<String, dynamic>? fertilizerPlan;

  // Seed Calculator State
  double seedRatePerHectare = 40; // kg/ha for rice by default
  double selectedAreaSeed = 1.0;

  // Yield Calculator State
  // (Yield calculator removed per feature request)

  @override
  void initState() {
    super.initState();
    _fertilizerService = FertilizerGuidanceService();
    _calculateFertilizer();
    _fertilizerService = FertilizerGuidanceService();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateFertilizer() {
    setState(() {
      fertilizerPlan = _fertilizerService.getFertilizerPlan(
        selectedCrop,
        areaInHectares,
      );
    });
  }

  double _areaInHectares(double value, String unit) {
    switch (unit) {
      case 'hectare':
        return value;
      case 'bigha': // 1 bigha ≈ 0.66 hectares (Bangladesh)
        return value * 0.66;
      case 'acre': // 1 acre ≈ 0.405 hectares
        return value * 0.405;
      case 'decimal': // 1 decimal ≈ 0.004 hectares
        return value * 0.004;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          widget.mode == 'seed' ? 'Seed Calculator' : 'Fertilizer Calculator',
        ),
        centerTitle: true,
      ),
      body: widget.mode == 'seed'
          ? _buildSeedCalculatorWithLabel(theme)
          : _buildFertilizerCalculatorWithLabel(theme),
    );
  }

  Widget _buildFertilizerCalculatorWithLabel(ThemeData theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fertilizer Calculator is under development. Results are for reference only.',
                  style: TextStyle(color: Colors.orange[900], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildFertilizerCalculator(theme)),
      ],
    );
  }

  Widget _buildFertilizerCalculator(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              'Based on Bangladesh Agricultural Research Council (BARC) recommendations',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.blue[900],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Crop Selection
          Text(
            'Select Crop',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedCrop,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCrop = value;
                  _calculateFertilizer();
                });
              }
            },
            isExpanded: true,
            items: _fertilizerService
                .getAvailableCrops()
                .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Area Input
          Text(
            'Farm Area',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter area',
                    labelText: 'Area',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      areaInHectares = double.tryParse(value) ?? areaInHectares;
                      _calculateFertilizer();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: 'hectare',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'hectare', child: Text('ha')),
                    DropdownMenuItem(value: 'bigha', child: Text('bigha')),
                    DropdownMenuItem(value: 'acre', child: Text('acre')),
                    DropdownMenuItem(value: 'decimal', child: Text('decimal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        areaInHectares = _areaInHectares(areaInHectares, value);
                        _calculateFertilizer();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Results
          if (fertilizerPlan != null) ...[
            Text(
              'Fertilizer Requirements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildFertilizerCard(
              theme,
              'Nitrogen (N)',
              '${fertilizerPlan!['npkValues']['nitrogen']} kg',
              'Urea (46% N): ${fertilizerPlan!['commonFertilizers']['urea']} kg',
              Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildFertilizerCard(
              theme,
              'Phosphorus (P)',
              '${fertilizerPlan!['npkValues']['phosphorus']} kg',
              'TSP (46% P₂O₅): ${fertilizerPlan!['commonFertilizers']['tsp']} kg',
              Colors.green,
            ),
            const SizedBox(height: 12),

            _buildFertilizerCard(
              theme,
              'Potassium (K)',
              '${fertilizerPlan!['npkValues']['potassium']} kg',
              'MOP (60% K₂O): ${fertilizerPlan!['commonFertilizers']['mop']} kg',
              Colors.orange,
            ),
            const SizedBox(height: 20),

            // Organic Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌱 Organic Fertilizer',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fertilizerPlan!['organicRecommendation'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Application Tips',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fertilizerPlan!['notes'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFertilizerCard(
    ThemeData theme,
    String title,
    String amount,
    String commercial,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            commercial,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedCalculatorWithLabel(ThemeData theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seed Calculator is under development. Results are for reference only.',
                  style: TextStyle(color: Colors.orange[900], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSeedCalculator(theme)),
      ],
    );
  }

  Widget _buildSeedCalculator(ThemeData theme) {
    const seedRates = {
      'rice': 40,
      'wheat': 100,
      'maize': 20,
      'lentil': 40,
      'potato': 2500,
      'tomato': 600,
      'onion': 8,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seed Requirement Calculator',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Text('Select Crop', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedCrop,
            onChanged: (value) {
              if (value != null && seedRates.containsKey(value)) {
                setState(() {
                  selectedCrop = value;
                  seedRatePerHectare = seedRates[value]!.toDouble();
                });
              }
            },
            isExpanded: true,
            items: seedRates.keys
                .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                .toList(),
          ),
          const SizedBox(height: 20),

          Text('Farm Area', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter area in hectares',
              labelText: 'Area (hectares)',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                selectedAreaSeed = double.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: 24),

          // Result
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seed Needed',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate: ${seedRatePerHectare.toStringAsFixed(0)} kg/ha',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Area: ${selectedAreaSeed.toStringAsFixed(2)} ha',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${(seedRatePerHectare * selectedAreaSeed).toStringAsFixed(2)} kg',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
